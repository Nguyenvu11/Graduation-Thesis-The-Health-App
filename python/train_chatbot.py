import json
import pickle

# Load datasets
def load_data():
    with open('assets/disease.json', 'r', encoding='utf-8') as file:
        disease_data = json.load(file)
    with open('assets/ehealth.json', 'r', encoding='utf-8') as file:
        ehealth_data = json.load(file)
    return disease_data, ehealth_data

# Process data for disease matching
def process_disease_data(disease_data):
    disease_symptom_map = {}
    for key, entry in disease_data.items():
        for symptom in entry.get("symptoms", []):
            if symptom.lower() not in disease_symptom_map:
                disease_symptom_map[symptom.lower()] = []
            disease_symptom_map[symptom.lower()].extend(entry.get("disease", []))
    return disease_symptom_map

# Process data for remedies and prevention
def process_ehealth_data(ehealth_data):
    prevention_map = {}
    for entry in ehealth_data:
        for tag in entry.get("tags", []):
            if tag.lower() not in prevention_map:
                prevention_map[tag.lower()] = []
            prevention_map[tag.lower()].append(entry.get("answer", ""))
    return prevention_map

# Main processing and saving
def main():
    disease_data, ehealth_data = load_data()

    # Create mappings
    disease_symptom_map = process_disease_data(disease_data)
    prevention_map = process_ehealth_data(ehealth_data)

    # Save processed data
    with open('disease_symptom_map.pkl', 'wb') as f:
        pickle.dump(disease_symptom_map, f)
    with open('prevention_map.pkl', 'wb') as f:
        pickle.dump(prevention_map, f)

    print("Data processing complete. Files saved.")

if __name__ == "__main__":
    main()
