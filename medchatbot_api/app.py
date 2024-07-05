import random
import json
import pickle
import numpy as np
import nltk
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
import string
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import tensorflow as tf

nltk.download('punkt')
nltk.download('wordnet')
nltk.download('stopwords')

lemmatizer = WordNetLemmatizer()
stop_words = set(stopwords.words('english'))

# Load the trained model and other necessary files
model = tf.keras.models.load_model('medchatbot_api/chatbotmodel.h5')
intents = json.loads(open('medchatbot_api/intents.json').read())
words = pickle.load(open('medchatbot_api/words.pkl', 'rb'))
classes = pickle.load(open('medchatbot_api/classes.pkl', 'rb'))

ignore_words = [
    'i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', "you're", 
    "you've", "you'll", "you'd", 'your', 'yours', 'yourself', 'yourselves', 'he', 
    'him', 'his', 'himself', 'she', "she's", 'her', 'hers', 'herself', 'it', "it's", 
    'its', 'itself', 'they', 'them', 'their', 'theirs', 'themselves', 'am', 'is', 
    'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 
    'do', 'does', 'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 
    'because', 'as', 'until', 'while', 'of', 'at', 'by', 'for', 'with', 'about', 
    'against', 'between', 'into', 'through', 'during', 'before', 'after', 'above', 
    'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 
    'again', 'further', 'then', 'once', 'here', 'there', 'when', 'where', 'why', 
    'how', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 
    'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 
    's', 't', 'can', 'will', 'just', 'don', "don't", 'should', "should've", 'now', 
    'd', 'll', 'm', 'o', 're', 've', 'y', 'ain', 'aren', "aren't", 'couldn', 
    "couldn't", 'didn', "didn't", 'doesn', "doesn't", 'hadn', "hadn't", 'hasn', 
    "hasn't", 'haven', "haven't", 'isn', "isn't", 'ma', 'mightn', "mightn't", 
    'mustn', "mustn't", 'needn', "needn't", 'shan', "shan't", 'shouldn', "shouldn't", 
    'wasn', "wasn't", 'weren', "weren't", 'won', "won't", 'wouldn', "wouldn't"
]

# Preprocess text by tokenizing, removing punctuation, lowering case, removing stopwords, and lemmatizing
def preprocess_text(text):
    tokens = nltk.word_tokenize(text)
    tokens = [word.lower() for word in tokens if word not in string.punctuation]
    tokens = [word for word in tokens if word not in stop_words and word not in ignore_words]
    tokens = [lemmatizer.lemmatize(word) for word in tokens]
    return ' '.join(tokens)

# Clean up sentence using the new preprocess function
def clean_up_sentence(sentence):
    return preprocess_text(sentence).split()

# Create a bag-of-words model from the preprocessed sentence
def bow(sentence, words, show_details=True):
    sentence_words = clean_up_sentence(sentence)
    bag = [0] * len(words)
    for s in sentence_words:
        for i, w in enumerate(words):
            if w == s:
                bag[i] = 1
    return np.array(bag)

# Find the most similar response using cosine similarity
def find_most_similar_response(user_input, intents_json):
    user_input_processed = preprocess_text(user_input)
    
    # Combine all patterns and preprocess them
    all_patterns = [intent['patterns'] for intent in intents_json['intents']]
    flat_patterns = [item for sublist in all_patterns for item in sublist]
    processed_patterns = [preprocess_text(pattern) for pattern in flat_patterns]
    
    # Add user input to the end of processed patterns
    processed_patterns.append(user_input_processed)
    
    # Calculate TF-IDF and cosine similarity
    vectorizer = TfidfVectorizer().fit_transform(processed_patterns)
    vectors = vectorizer.toarray()
    cosine_similarities = cosine_similarity([vectors[-1]], vectors[:-1])
    
    # Find the highest similarity score
    max_similarity_index = cosine_similarities.argmax()
    return max_similarity_index

# Predict the class of an input sentence
def predict_class(sentence, model):
    p = bow(sentence, words, show_details=False)
    res = model.predict(np.array([p]))[0]
    ERROR_THRESHOLD = 0.25
    results = [[i, r] for i, r in enumerate(res) if r > ERROR_THRESHOLD]
    results.sort(key=lambda x: x[1], reverse=True)
    return_list = []
    for r in results:
        return_list.append({"intent": classes[r[0]], "probability": r[1]})
    return return_list

# Get the response based on the predicted class
def get_response(intents_list, intents_json):
    if not intents_list:
        return "Sorry, I didn't get that."
    
    tag = intents_list[0]['intent']
    confidence = intents_list[0]['probability']
    
    if confidence < 0.5:
        # Use cosine similarity to find the best matching response
        max_similarity_index = find_most_similar_response(tag, intents_json)
        flat_patterns = [item for sublist in [intent['patterns'] for intent in intents_json['intents']] for item in sublist]
        best_match_intent = None
        for intent in intents_json['intents']:
            if flat_patterns[max_similarity_index] in intent['patterns']:
                best_match_intent = intent
                break
        if best_match_intent:
            return random.choice(best_match_intent['responses'])
        else:
            return "Sorry, I didn't get that."

    list_of_intents = intents_json['intents']
    for i in list_of_intents:
        if i['tag'] == tag:
            result = random.choice(i['responses'])
            break
    return result

# Main chat function
def chat():
    print("Chatbot is running! (type 'quit' or 'exit' to stop)")
    """
    while True:
        user_input = input("You: ")
        if user_input.lower() in ["quit", "exit"]:
            break
        intents_list = predict_class(user_input, model)
        response = get_response(intents_list, intents)
        print("Chatbot:", response)
    """

if __name__ == "__main__":
    chat()
