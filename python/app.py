from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import random

# Flask App
app = Flask(__name__)
CORS(app)

# Load processed data
with open('disease_symptom_map.pkl', 'rb') as f:
    disease_symptom_map = pickle.load(f)
with open('prevention_map.pkl', 'rb') as f:
    prevention_map = pickle.load(f)

# Function to predict diseases based on symptoms
def find_diseases(symptoms):
    matches = []
    for symptom in symptoms:
        symptom = symptom.lower().strip()
        if symptom in disease_symptom_map:
            matches.extend(disease_symptom_map[symptom])
    return list(set(matches))[:1]  # Return only 1 disease

# Function to find remedies or prevention methods
def find_remedies(disease):
    if disease.lower() in prevention_map:
        return prevention_map[disease.lower()]
    return []

@app.route('/predict', methods=['POST'])
def predict():
    user_input = request.json.get('message', '').strip()
    if not user_input:
        return jsonify({'response': "Please provide symptoms to analyze."}), 400

    # Parse symptoms
    symptoms = [symptom.strip().lower() for symptom in user_input.split(',')]

    # Predict diseases
    matched_diseases = find_diseases(symptoms)

    # Build response
    response = ""
    if matched_diseases:
        disease = matched_diseases[0]
        remedies = find_remedies(disease)
        response += f"Possible disease: {disease}. \n"
        if remedies:
            response += f"Prevention/Remedy: {random.choice(remedies)} \n"
    else:
        response = "Sorry, no matching diseases found for the provided symptoms."

    return jsonify({'tag': "disease_prediction", 'response': response})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
