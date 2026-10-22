FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
# The classifier is over Cloud Run's 32 MiB response limit, so it is served from Cloud Storage.
ARG VITE_CLASSIFIER_URL=https://storage.googleapis.com/leafcheckup-models/plant_disease_model.onnx
ENV VITE_CLASSIFIER_URL=$VITE_CLASSIFIER_URL
RUN npm run build

FROM nginx:1.29-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
