FROM python:3

RUN pip install --upgrade pip 

# COPY requirements.txt /tmp/requirements.txt
# RUN pip install -r /tmp/requirements.txt

RUN apt-get update && apt-get install -y zsh git curl
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN chsh -s $(which zsh)
CMD ["zsh"]