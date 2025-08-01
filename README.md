## 概要
ブロックチェーン技術を活用した、画像ハッシュベースの会員証管理システムです。Polygon Amoyテストネット上にデプロイされたスマートコントラクトにより、改ざん検出機能付きの会員証発行・認証・失効を実現します。

## 特徴

- 🔐 **画像ハッシュベース認証**: 会員証画像のハッシュ値による改ざん検出
- 👥 **発行者権限管理**: 認可された発行者のみが会員証を発行可能
- ⏰ **有効期限管理**: 会員証の有効期限設定と自動失効
- 🚫 **失効機能**: 発行者または管理者による会員証の無効化
- 🔍 **透明性**: ブロックチェーン上での全取引記録の公開

## デプロイ情報

- **ネットワーク**: Polygon Amoy Testnet
- **コントラクトアドレス**: `0x704650f12B5b367335AA83A5A64F54cE61D0debe`
- **検証状況**: ✅ PolygonScanで検証済み
- **PolygonScan**: [https://amoy.polygonscan.com/address/0x704650f12B5b367335AA83A5A64F54cE61D0debe](https://amoy.polygonscan.com/address/0x704650f12B5b367335AA83A5A64F54cE61D0debe)

## 技術スタック

- **Solidity**: ^0.8.28
- **Hardhat**: 開発・テスト・デプロイ環境
- **TypeScript**: 型安全な開発
- **Docker**: コンテナ化された開発環境

## プロジェクト構造

```
app/
├── contracts/
│   └── MembershipVC.sol      # メインコントラクト
├── ignition/
│   └── modules/
│       └── MembershipVC.ts   # デプロイスクリプト
├── test/                     # テストファイル
├── artifacts/                # コンパイル成果物
├── hardhat.config.ts         # Hardhat設定
├── package.json              # 依存関係
└── .env                      # 環境変数
```

## セットアップ

### 前提条件

- Node.js 18+
- Docker & Docker Compose
- MetaMask（Amoyテストネット設定済み）

### インストール

```bash
# リポジトリクローン
git clone <repository-url>
cd Blockchain-Membership-SmartContract

# Docker環境起動
docker-compose up -d

# コンテナ内で依存関係インストール
docker-compose exec hardhat npm install
```

### 環境変数設定

`.env`ファイルを作成：

```bash
# デプロイに必要な設定
PRIVATE_KEY=your_private_key_here

# コントラクト検証用（オプション）
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

## 使用方法

### コンパイル

```bash
docker-compose exec hardhat npm run compile
```

### デプロイ

```bash
# Amoyテストネットにデプロイ
docker-compose exec hardhat npm run deploy:amoy

# Sepoliaテストネットにデプロイ
docker-compose exec hardhat npm run deploy:sepolia
```

### テスト

```bash
docker-compose exec hardhat npm test
```

## コントラクト機能

### 主要関数

#### 管理者機能
- `authorizeIssuer(address issuer)`: 発行者を認可
- `revokeIssuer(address issuer)`: 発行者の認可を取消

#### 発行者機能
- `issueMembership(bytes32 imageHash, address holder, uint256 expiresAt)`: 会員証発行
- `revokeMembership(bytes32 credentialId)`: 会員証失効

#### 検証機能
- `verifyMembership(bytes32 credentialId, bytes32 imageHash)`: 会員証認証
- `getCredential(bytes32 credentialId)`: 会員証詳細取得
- `isCredentialActive(bytes32 credentialId)`: 会員証有効性確認

#### ユーティリティ
- `isAuthorizedIssuer(address issuer)`: 発行者認可状況確認

### イベント

- `MembershipIssued`: 会員証発行時
- `MembershipRevoked`: 会員証失効時
- `IssuerAuthorized`: 発行者認可時
- `IssuerRevoked`: 発行者認可取消時

## セキュリティ

- ✅ **アクセス制御**: 管理者・発行者権限の厳格な管理
- ✅ **改ざん検出**: 画像ハッシュによる整合性確認
- ✅ **重複防止**: 同一会員証IDの重複発行防止
- ✅ **有効期限**: 自動的な期限切れ処理

## 開発

### ローカル開発

```bash
# ローカルHardhatネットワーク起動
docker-compose exec hardhat npx hardhat node

# ローカルにデプロイ
docker-compose exec hardhat npm run deploy:local
```

### テスト実行

```bash
# 全テスト実行
docker-compose exec hardhat npm test

# カバレッジ確認
docker-compose exec hardhat npx hardhat coverage
```

## ライセンス

MIT License

## 貢献

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## サポート

問題や質問がある場合は、GitHubのIssuesを作成してください。

---

**注意**: このプロジェクトはテストネット用です。本番環境での使用前に十分なテストとセキュリティ監査を実施してください。