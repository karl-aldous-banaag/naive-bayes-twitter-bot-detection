# Objective: The purpose of these case study is to implement the different
# analytics techniques discussed using real world data.

# 1. Develop a model using only one of the supervised or unsupervised
#  techniques discussed:
#   - Clustering
#   - Association Rules
#   - Decision Tree
#   - Naïve Bayes
#   - Regression Techniques
#   - SVM
#   - PCA
#   - etc.

# 2. Use any real-world dataset available online that is applicable on the
#  technique you have chosen.

# 3. Give a brief write up each case studies including but are not limited to
#   - Introduction
#   - Significance
#   - Scope and Limitation
# Indicate the dependent variables and the predictor variables. 

# 4. Discuss the models’ diagnostics. For models that allows for prediction,
#  illustrate on how the model is used for prediction by giving specific
#  examples.

# 5. Include complete documentation of R codes and the resulting output/s.

# 6. You may work solo or by pairs. 

# Deadline for submission: October 28, 2022


# Import relevant libraries
library(ggplot2)
library(ggcorrplot)
library(dplyr)
library(tidyr)
library(stringr)
library(akmedoids)

# Import the data
twitter_data <- read.csv("twitter_output.csv")

### DATA CLEANING
# Fill in average_tweets_per_day and account_age
created_at_vector <- pull(twitter_data, created_at)
created_at_vector <- paste(
        substring(created_at_vector, first = 5, last = 10), 
        substring(created_at_vector, first = 27, last = 30)
)
created_at_vector <- as.Date(created_at_vector, "%b %d %Y")
twitter_data["created_at"] <- created_at_vector
twitter_data["account_age"] <- as.numeric(Sys.Date() - created_at_vector)
twitter_data["average_tweets_per_day"] <-
        twitter_data[,"statuses_count"] / twitter_data[,"account_age"]

# Create has_bot_in_description column
twitter_data["description"] <- tolower(twitter_data[, "description"])
twitter_data["has_bot_in_description"] <-
        grepl("bot", twitter_data[,"description"])

# Remove columns with high inconsistency
twitter_data <- twitter_data[, -which(names(twitter_data) %in% c(
        "id",
        "location",
        "description",
        "profile_background_image",
        "profile_image",
        "screen_name"
))]

# Remove lang because none of the values in it exist
twitter_data <- twitter_data[, -which(names(twitter_data) %in% c(
        "lang"
))]

# Remove created_at to increase usability of data
twitter_data <- twitter_data[, -which(names(twitter_data) %in% c(
        "created_at"
))]

# Turn all booleans into True/False strings
twitter_data <- sapply(twitter_data, function(y) {
        if (class(y) == "logical") {
                return(str_to_title(as.character(y)))
        }
        else { return(y) }
})
twitter_data <- as.data.frame(twitter_data)

# Count NA per row
na_count <- sapply(as.data.frame(twitter_data),
                   function(y) sum(length(which(is.na(y)))))
na_count <- data.frame(na_count)
na_count

# Only around 5% of data will be gone if the researcher deleted all rows with
# na values, so it was deleted.
twitter_data <- na.omit(twitter_data)

# Turn character values that are supposed to be numeric into numeric values
twitter_data[,"favourites_count"] <- apply(
        as.matrix(twitter_data[,"favourites_count"]),
        1, as.numeric)
twitter_data[,"followers_count"] <- apply(
        as.matrix(twitter_data[,"followers_count"]),
        1, as.numeric)
twitter_data[,"statuses_count"] <- apply(
        as.matrix(twitter_data[,"statuses_count"]),
        1, as.numeric)
twitter_data[,"average_tweets_per_day"] <- apply(
        as.matrix(twitter_data[,"average_tweets_per_day"]),
        1, as.numeric)
twitter_data[,"account_age"] <- apply(
        as.matrix(twitter_data[,"account_age"]),
        1, as.numeric)

# Bin numeric variables
# function for making functions for binning
make_bin_function <- function(values) {
        wss_measurements <- numeric(10)
        for (k in 1:10) {
                kmm <- kmeans(values, k)
                wss_measurements[k] <- kmm$tot.withinss
        }

        elbow_num <- round(elbow_point(c(1:10), wss_measurements)$x,
                digits = 0)

        kmm_best <- kmeans(values, elbow_num)
        return_obj <- list()
        return_obj[["model"]] <- kmm_best 
        return_obj[["assign"]] <- function(new_val) {
                bc_i <- 0 # best cluster index
                bc_d <- NULL # best cluster distance
                # iterate through cluster indices (index as c_i)
                for (c_i in 1:length(kmm_best$centers)) {
                        # distance to cluster
                        c_d <- abs(new_val - kmm_best$centers[c_i])
                        if (is.null(bc_d)) {
                                bc_d <- c_d
                                bc_i <- c_i
                        } else {
                                if (bc_d > c_d) {
                                        bc_d <- c_d
                                        bc_i <- c_i
                                }
                        }
                }
                as.character(bc_i)
        }
        return(return_obj)
}

# Make binning functions
favourites_bin_func <- make_bin_function(twitter_data[,"favourites_count"])
followers_bin_func <- make_bin_function(twitter_data[,"followers_count"])
statuses_bin_func <- make_bin_function(twitter_data[,"statuses_count"])
avg_tweets_bin_func <- make_bin_function(twitter_data[,"average_tweets_per_day"])
age_bin_func <- make_bin_function(twitter_data[,"account_age"])

# Apply binning functions
twitter_data[,"favourites_count"] <- apply(
        as.matrix(twitter_data[,"favourites_count"]),
        1, favourites_bin_func$assign)
twitter_data[,"followers_count"] <- apply(
        as.matrix(twitter_data[,"followers_count"]),
        1, followers_bin_func$assign)
twitter_data[,"statuses_count"] <- apply(
        as.matrix(twitter_data[,"statuses_count"]),
        1, statuses_bin_func$assign)
twitter_data[,"average_tweets_per_day"] <- apply(
        as.matrix(twitter_data[,"average_tweets_per_day"]),
        1, avg_tweets_bin_func$assign)
twitter_data[,"account_age"] <- apply(
        as.matrix(twitter_data[,"account_age"]),
        1, age_bin_func$assign)

# Convert data to dataframe
twitter_df <- as.data.frame(twitter_data)

# Converting all data to character type
twitter_df <- sapply(twitter_df, as.character)

# Save cleaned dataset
write.csv(twitter_data, "twitter_clean.csv")

### UNDERSTANDING THE DATA
attach(twitter_data)
summary(twitter_data)

# Count bots and humans
type_count <- data.frame(account_type = twitter_data[,"account_type"])
type_count <- as.data.frame(table(type_count))
type_count["percent"] <- (type_count$Freq / sum(type_count$Freq)) * 100
type_count <- type_count[c(2, 1),] # Switch row order

ggplot(type_count, aes(x='', y = type_count$percent,
        fill = type_count$account_type)) + 
        geom_bar(width = 1, stat = "identity") + 
        coord_polar("y", start=0) + 
        labs(title = "Pie Chart of Bot and Human Accounts") + 
        xlab("") + ylab("Percent")

# Bar Plots of Columns
ggplot(twitter_data) + geom_histogram(aes(x = favourites_count), bins = 10)
ggplot(twitter_data) + geom_histogram(aes(x = followers_count), bins = 10)
ggplot(twitter_data) + geom_histogram(aes(x = statuses_count), bins = 10)
hist(average_tweets_per_day[!is.na(average_tweets_per_day) &
        average_tweets_per_day < 100])
ggplot(twitter_data) + geom_histogram(aes(x = account_age), bins = 10)

# Correlation Matrix
twitter_corr <- cor_pmat(twitter_data[,c("favourites_count", "followers_count",
        "statuses_count", "average_tweets_per_day", "account_age")])
ggcorrplot(twitter_corr)

detach(twitter_data)

### MODELING

# Splitting the Data into Train and Test
set.seed(123) # set seed for randomization
train_size <- floor(0.8 * nrow(twitter_df))

train_indices <- sample(seq_len(nrow(twitter_df)), size = train_size)
train_data <- as.data.frame(twitter_df[train_indices,])
test_data <- as.data.frame(twitter_df[-train_indices,])

# Creating Model
attach(train_data)

# Create custom function for making Naive Bayes Model
custom_naive_bayes <- function(in_data, dep_var_name) {
        out_list <- list(data = in_data)
        indep_var_names <- names(in_data)[-which(names(in_data) %in% c(dep_var_name))]
        
        # Create coefficients for predicting output
        tprior <- table(in_data[dep_var_name])
        tprior <- tprior/sum(tprior)

        count_list <- list(tprior = tprior)
        for (indep_var_name in indep_var_names) {
                indep_var <- in_data[indep_var_name]
                unique_ins <- unique(indep_var)
                
                for (unique_in in unique_ins) {
                        varCount <- table(in_data[,c(dep_var_name, indep_var_name)])
                        varCount <- varCount / rowSums(varCount)
                        count_list[[indep_var_name]] <- varCount 
                }
        }
        out_list[["coefficients"]] <- count_list

        # Create function for predicting output
        unique_outs <- unique(in_data[,dep_var_name])
        out_list[["predict"]] <- function(instances) {
                pred_col_name <- paste("predicted_", dep_var_name)
                out_chances <- list(occupy = rep(1, nrow(instances)))

                for (out in unique_outs) {
                        out_chance <- as.numeric(tprior[out])
                        for (colname in indep_var_names) { out_chance <- out_chance * count_list[[colname]][out, instances[,colname]] }
                        out_chances[[out]] <- out_chance
                }

                out_chances <- as.data.frame(do.call(cbind, out_chances))[,-1]
                res_indices <- apply(out_chances, 1, function(x) { which(x == max(x)) })

                predict_list <- list(computations = out_chances, results = unique_outs[res_indices])
                predict_list
        }
        
        out_list
}

twitter_model <- custom_naive_bayes(train_data, "account_type")
twitter_test <- twitter_model$predict(test_data)

# Evaluating Model
model_test <- data.frame(actual = test_data$account_type,
                         prediction = twitter_test$results)
model_test$was_right <- model_test$actual == model_test$prediction

tp <- nrow(model_test[model_test$actual == "bot" & model_test$prediction == "bot",])
tn <- nrow(model_test[model_test$actual == "human" & model_test$prediction == "human",])
fp <- nrow(model_test[model_test$actual == "human" & model_test$prediction == "bot",])
fn <- nrow(model_test[model_test$actual == "bot" & model_test$prediction == "human",])

# Making Confusion Matrix
conf_mat <- matrix(c(tp, fp, fn, tn), ncol=2, byrow = TRUE)

# Computation of metrics
metrics <- data.frame(
        accuracy = (tp+tn)/(tp+tn+fp+fn),
        precision = tp/(tp+fp),
        recall = tp/(tp+fn),
        f1_score = (2*(tp/(tp+fp))*(tp/(tp+fn)))/((tp/(tp+fp))+(tp/(tp+fn)))
)

# Examples

# @giveitupfor15 (bot)
one_bot <- data.frame(
        default_profile = "False", default_profile_image = "False",
        favourites_count = favourites_bin_func$assign(3),
        followers_count = followers_bin_func$assign(210042),
        geo_enabled = "False", statuses_count = statuses_bin_func$assign(80),
        verified = "False",
        average_tweets_per_day = avg_tweets_bin_func$assign(80/2446),
        account_age = age_bin_func$assign(2446),
        has_bot_in_description = "True"
)
one_bot_test <- twitter_model$predict(one_bot)

# @gothixTV (human)
one_human <- data.frame(
        default_profile = "False", default_profile_image = "False",
        favourites_count = favourites_bin_func$assign(13452),
        followers_count = followers_bin_func$assign(44722),
        geo_enabled = "False", statuses_count = statuses_bin_func$assign(17832),
        verified = "False",
        average_tweets_per_day = avg_tweets_bin_func$assign(17832/5085),
        account_age = age_bin_func$assign(5085),
        has_bot_in_description = "False"
)
one_human_test <- twitter_model$predict(one_human)

