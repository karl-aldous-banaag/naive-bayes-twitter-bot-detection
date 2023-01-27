# Naïve Bayes Model for Detecting Twitter Bots

## Objective
The purpose of this project is to make a Naïve Bayes model to detect twitter bots.

## Technologies
* R 
* Python

## Dataset
### Source
https://www.kaggle.com/datasets/davidmartngutirrez/twitter-bots-accounts

## Columns Derived from Twitter API
### Data Used from Twitter API
<table>
    <tr>
        <th>Value Name</th>
        <th>Description of Information in Twitter API Documentation</th>
    </tr>
    <tr>
        <td>created_at</td>
        <td>The UTC datetime that the user account was created on Twitter.</td>
    </tr>
    <tr>
        <td>default_profile</td>
        <td>When true, indicates that the user has not altered the theme or background of their user profile.</td>
    </tr>
    <tr>
        <td>default_profile_image</td>
        <td>When true, indicates that the user has not uploaded their own profile image and a default image is used instead.</td>
    </tr>
    <tr>
        <td>description</td>
        <td>The user-defined UTF-8 string describing their account.</td>
    </tr>
    <tr>
        <td>favourites_count</td>
        <td>The number of Tweets this user has liked in the account’s lifetime. British spelling used in the field name for historical reasons.</td>
    </tr>
    <tr>
        <td>geo_enabled</td>
        <td>Value will be set to null.  Still available via GET account/settings. This field must be true for the current user to attach geographic data when using POST statuses / update.</td>
    </tr>
    <tr>
        <td>lang</td>
        <td>Value will be set to null. Still available via GET account/settings as language.</td>
    </tr>
    <tr>
        <td>location</td>
        <td>The user-defined location for this account’s profile. Not necessarily a location, nor machine-parseable. This field will occasionally be fuzzily interpreted by the Search service.</td>
    </tr>
    <tr>
        <td>screen_name</td>
        <td>The screen name, handle, or alias that this user identifies themselves with. screen_names are unique but subject to change. Use id_str as a user identifier whenever possible. Typically a maximum of 15 characters long, but some historical accounts may exist with longer names.</td>
    </tr>
    <tr>
        <td>statuses_count</td>
        <td>The number of Tweets (including retweets) issued by the user.</td>
    </tr>
    <tr>
        <td>verified</td>
        <td>When true, indicates that the user has a verified account.</td>
    </tr>
</table>

A column named `has_bot_in_description` was derived from the `description` value from the Twitter API. When the description of a Twitter account has the word "bot" in it, the corresponding value in the column is set to true.

## Data Collection
A Jupyter Notebook was used to read the account IDs in a [Kaggle dataset](https://www.kaggle.com/datasets/davidmartngutirrez/twitter-bots-accounts). The data pertaining to the Twitter accounts was retrieved through the [Twitter API](https://developer.twitter.com/en/docs/twitter-api).

## How the Classification Works
The R program computes the probability of a Twitter account having a certain property given that it is or is not a bot. When given the properties of a Twitter account, it multiplies probabilities pertaining to the properties of the Twitter account. If a Twitter bot is more likely to be a bot given its properties, it is classified as a bot. Otherwise, it is not classified as a bot.


## Results
### Coefficients
#### tprior
<table>
    <tr>
        <th>bot</th>
        <th>human</th>
    </tr>
    <tr>
        <td>0.3315568</td>
        <td>0.6684432</td>
    </tr>
</table>

#### default_profile
<table>
    <tr>
        <th></th>
        <th>False</th>
        <th>True</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.3769036</td>
        <td>0.6230964</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.6823856</td>
        <td>0.3176144</td>
    </tr>
</table>

#### default_profile_image
<table>
    <tr>
        <th></th>
        <th>False</th>
        <th>True</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.969437394</td>
        <td>0.030562606</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.992341586</td>
        <td>0.007658414</td>
    </tr>
</table>

#### favourites_count
<table>
    <tr>
        <th></th>
        <th>1</th>
        <th>2</th>
        <th>3</th>
        <th>4</th>
        <th>5</th>
        <th>6</th>
        <th>7</th>
        <th>8</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.0011632826</td>
        <td>0.0127961083</td>
        <td>0.0037013536</td>
        <td>0.0004230118</td>
        <td>0.0311971235</td>
        <td>0.0065566836</td>
        <td>0.0007402707</td>
        <td>0.9434221658</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.0076584138</td>
        <td>0.0809903483</td>
        <td>0.0197754931</td>
        <td>0.0004720940</td>
        <td>0.1866344943</td>
        <td>0.0403902644</td>
        <td>0.0026227444</td>
        <td>0.6614561477</td>
    </tr>
</table>

#### followers_count
<table>
    <tr>
        <th></th>
        <th>1</th>
        <th>2</th>
        <th>3</th>
        <th>4</th>
        <th>5</th>
        <th>6</th>
        <th>7</th>
        <th>8</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.9810702200</td>
        <td>0.0146996616</td>
        <td>0.0006345178</td>
        <td>0.0001057530</td>
        <td>0.0020093063</td>
        <td>0.0010575296</td>
        <td>0.0004230118</td>
        <td>0.0000000000</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.8563260596</td>
        <td>0.0976710029</td>
        <td>0.0104385229</td>
        <td>0.0005770038</td>
        <td>0.0298992866</td>
        <td>0.0038292069</td>
        <td>0.0009441880</td>
        <td>0.0003147293</td>
    </tr>
</table>

#### geo_enabled
<table>
    <tr>
        <th></th>
        <th>False</th>
        <th>True</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.7763325</td>
        <td>0.2236675</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.4069450</td>
        <td>0.5930550</td>
    </tr>
</table>

#### statuses_count
<table>
    <tr>
        <th></th>
        <th>1</th>
        <th>2</th>
        <th>3</th>
        <th>4</th>
        <th>5</th>
        <th>6</th>
        <th>7</th>
        <th>8</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.0298223350</td>
        <td>0.0016920474</td>
        <td>0.0581641286</td>
        <td>0.0054991540</td>
        <td>0.0008460237</td>
        <td>0.0096235195</td>
        <td>0.8773265651</td>
        <td>0.0170262267</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.0581200168</td>
        <td>0.0001573647</td>
        <td>0.1898342426</td>
        <td>0.0007868233</td>
        <td>0.0001049098</td>
        <td>0.0049832144</td>
        <td>0.7287033151</td>
        <td>0.0173101133</td>
    </tr>
</table>

#### verified
<table>
    <tr>
        <th></th>
        <th>False</th>
        <th>True</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.97176396</td>
        <td>0.02823604</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.70814100</td>
        <td>0.29185900</td>
    </tr>
</table>

#### average_tweets_per_day
<table>
    <tr>
        <th></th>
        <th>1</th>
        <th>2</th>
        <th>3</th>
        <th>4</th>
        <th>5</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.0070854484</td>
        <td>0.0587986464</td>
        <td>0.0244289340</td>
        <td>0.9088409475</td>
        <td>0.0008460237</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.0011540076</td>
        <td>0.1079521611</td>
        <td>0.0145824591</td>
        <td>0.8762064624</td>
        <td>0.0001049098</td>
    </tr>
</table>

#### account_age
<table>
    <tr>
        <th></th>
        <th>1</th>
        <th>2</th>
        <th>3</th>
        <th>4</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.2193316</td>
        <td>0.3459179</td>
        <td>0.2416455</td>
        <td>0.1931049</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.1632921</td>
        <td>0.2856693</td>
        <td>0.1348091</td>
        <td>0.4162295</td>
    </tr>
</table>

#### has_bot_in_description
<table>
    <tr>
        <th></th>
        <th>False</th>
        <th>True</th>
    </tr>
    <tr>
        <th>bot</th>
        <td>0.967956853</td>
        <td>0.032043147</td>
    </tr>
    <tr>
        <th>human</th>
        <td>0.995646244</td>
        <td>0.004353756</td>
    </tr>
</table>

## Confusion Matrix on Test Dataset
The testing dataset contains 20% of the whole dataset.

<table>
    <tr>
        <th></th>
        <th>Actual Bot</th>
        <th>Actual Human</th>
    </tr>
    <tr>
        <th>Predicted Bot</th>
        <td>1741</td>
        <td>1116</td>
    </tr>
    <tr>
        <th>Predicted Human</th>
        <td>658</td>
        <td>3615</td>
    </tr>
</table>

Given the confusion matrix, the model has an accuracy of about **75%**.