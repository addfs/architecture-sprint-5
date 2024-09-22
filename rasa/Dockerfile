FROM rasa/rasa:3.6.20-full

# Copy the current directory contents into the container at /app
COPY . /app
#pip install rasa[spacy] &&
USER root
RUN python -m spacy download ru_core_news_sm
#RUN pip3 install jieba