FROM node:18-alpine
WORKDIR /app

# 必要なパッケージをインストール
RUN apk add --no-cache bash git python3 make g++

# package.jsonをコピーして依存関係をインストール
COPY package*.json ./
RUN npm install

# ソースコードをコピー
COPY . .

# デフォルトコマンド
CMD ["bash"]
