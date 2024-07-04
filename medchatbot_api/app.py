import random
import json
import pickle
import numpy as np
import nltk
from nltk.stem import WordNetLemmatizer
import tensorflow as tf

# Ensure necessary NLTK downloads
nltk.download('punkt')
nltk.download('wordnet')

# Load trained model and auxiliary files
model = tf.keras.models.load_model('medchatbot_api/chatbotmodel.h5')
lemmatizer = WordNetLemmatizer()
intents = json.loads(open('medchatbot_api/intents.json').read())
words = pickle.load(open('medchatbot_api/words.pkl', 'rb'))
classes = pickle.load(open('medchatbot_api/classes.pkl', 'rb'))



def clean_up_sentence(sentence):
    # Tokenize the pattern and lemmatize each word
    sentence_words = nltk.word_tokenize(sentence)
    sentence_words = [lemmatizer.lemmatize(word.lower()) for word in sentence_words]
    return sentence_words

def bow(sentence, words, show_details=True):
    # Bag of words
    sentence_words = clean_up_sentence(sentence)
    bag = [0]*len(words)  
    for s in sentence_words:
        for i, w in enumerate(words):
            if w == s: 
                bag[i] = 1
    return np.array(bag)

def predict_class(sentence, model):
    # Predict the class (tag) of an input sentence
    p = bow(sentence, words, show_details=False)
    res = model.predict(np.array([p]))[0]
    ERROR_THRESHOLD = 0.25
    results = [[i, r] for i, r in enumerate(res) if r > ERROR_THRESHOLD]
    results.sort(key=lambda x: x[1], reverse=True)
    return_list = []
    for r in results:
        return_list.append({"intent": classes[r[0]], "probability": r[1]})
    return return_list

def get_response(intents_list, intents_json):
    if not intents_list:
        return "Sorry, I didn't get that."
    
    tag = intents_list[0]['intent']
    confidence = intents_list[0]['probability']
    
    # Check if the confidence is below the threshold
    if confidence < 0.5:
        return "Sorry, I didn't get that."
    
    list_of_intents = intents_json['intents']
    for i in list_of_intents:
        if i['tag'] == tag:
            result = random.choice(i['responses'])
            break
    return result

def chat():
    print("Chatbot is running! (type 'quit' or 'exit' to stop)")
    """while True:
        user_input = input("You: ")
        if user_input.lower() in ["quit", "exit"]:
            break
        intents_list = predict_class(user_input, model)
        response = get_response(intents_list, intents)
        print("Chatbot:", response)"""


if __name__ == "__main__":
    chat()
    