# Docker + PHP + Nginx + Adianti

### Estando no diretório onde se encontra o Dockerfile, usar esse comando para criar a imagem:

docker build -t marcelonees/adianti_nginx:php-7.4 .

### Caso seja alterado algo do arquivo de texto Dockerfile é necessário usar o comando novamente para atualizar a imagem:

docker build -t  .

### Para ver se a imagem foi criada:

docker images

### Para inicializar o container a partir da imagem:

docker run -d --network=host -p 880:880 -v $HOME/Documentos/template/:/var/www/html marcelonees/adianti_nginx:php-7.4

