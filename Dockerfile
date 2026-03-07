FROM nginx:alpine

# Copy website files to nginx html directory
COPY seven_wonders.html /usr/share/nginx/html/index.html
COPY images /usr/share/nginx/html/images

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
