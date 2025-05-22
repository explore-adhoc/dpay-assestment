FROM nginx:alpine

RUN mkdir -p /var/www/

COPY hello.txt /var/www/hello.txt

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
