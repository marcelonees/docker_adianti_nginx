# docker_adianti_nginx
Imagem docker para rodar o ambiente de desenvolvimento do Adianti

```
git clone git@github.com:marcelonees/docker_adianti_nginx.git
cd docker_adianti_nginx
docker build -t marcelonees/adianti_nginx:php-7.4 .
```

## Para inicializar o container a partir da imagem:

```
docker run -d --network=host -p 880:880 -v $HOME/Documentos/sua_template_adianti/:/var/www/html marcelonees/adianti_nginx:php-7.4
```

### Caso seja alterado algo do arquivo de texto Dockerfile é necessário usar o comando novamente para atualizar a imagem:

```
docker build -t  .
```

### Para ver se a imagem foi criada:

```
docker images
```

