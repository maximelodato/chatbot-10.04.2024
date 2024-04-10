require 'http'
require 'json'
require 'dotenv'
Dotenv.load('.env')

# Création de la clé API et définition de l'URL
api_key = ENV["OPENAI_API_KEY"]
url = "https://api.openai.com/v1/chat/completions"

# Initialisation de l'historique de la conversation
chat_history = []

# Boucle de conversation
loop do
  # Demande à l'utilisateur de saisir un message
  puts "Votre message (ou 'exit' pour quitter) : "
  user_input = gets.chomp
  
  # Quitte la boucle si l'utilisateur entre 'exit'
  break if user_input.downcase == 'exit'

  # Ajout du message de l'utilisateur à l'historique de la conversation
  chat_history << { "role" => "user", "content" => user_input }

  # Création des données à envoyer à l'API OpenAI
  data = {
    "messages" => chat_history,
    "max_tokens" => 150,
    "temperature" => 0,
    "model" => "gpt-3.5-turbo"
  }

  # Envoi de la requête à l'API OpenAI
  response = HTTP.post(url, headers: {"Content-Type" => "application/json", "Authorization" => "Bearer #{api_key}"}, body: data.to_json)
  response_body = JSON.parse(response.body.to_s)

  # Vérification de la validité de la réponse
  if response_body.key?('choices') && response_body['choices'][0].key?('message') && response_body['choices'][0]['message'].key?('content')
    response_string = response_body['choices'][0]['message']['content'].strip

    # Ajout de la réponse du chatbot à l'historique de la conversation
    chat_history << { "role" => "system", "content" => response_string }

    # Affichage de la réponse du chatbot
    puts "Réponse du chatbot :"
    puts response_string
  else
    puts "Erreur: la structure de la réponse est invalide."
  end
end

# Affichage de l'historique de la conversation après la fin de la conversation
puts "Historique de la conversation :"
chat_history.each do |item|
  puts "#{item['role'].capitalize} : #{item['content']}"
end
