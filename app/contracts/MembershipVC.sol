// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title MembershipVC - DID/VC会員証管理コントラクト
 * @dev 画像ハッシュベースの会員証発行・認証・失効を管理
 */
contract MembershipVC {
    
    // ========================================
    // データ構造定義
    // ========================================
    
    /**
     * @dev 会員証情報を格納する構造体
     */
    struct MemberCredential {
        bytes32 imageHash;      // 処理済み画像のハッシュ値（改ざん検出用）
        address holder;         // 会員証保持者のウォレットアドレス
        address issuer;         // 発行者のウォレットアドレス
        uint256 issuedAt;      // 発行日時（ブロックタイムスタンプ）
        uint256 expiresAt;     // 有効期限（ブロックタイムスタンプ）
        bool active;           // 有効フラグ（失効処理用）
    }
    
    // ========================================
    // ストレージ変数
    // ========================================
    
    /// @dev 会員証ID → 会員証情報のマッピング
    mapping(bytes32 => MemberCredential) public credentials;
    
    /// @dev 認可された発行者のマッピング（発行者認証・権限管理）
    mapping(address => bool) public authorizedIssuers;
    
    /// @dev システム管理者アドレス
    address public admin;
    
    // ========================================
    // イベント定義
    // ========================================
    
    /// @dev 会員証発行時に発火するイベント
    event MembershipIssued(bytes32 indexed credentialId, address indexed holder, address indexed issuer);
    
    /// @dev 会員証失効時に発火するイベント
    event MembershipRevoked(bytes32 indexed credentialId);
    
    /// @dev 発行者認可時に発火するイベント
    event IssuerAuthorized(address indexed issuer);
    
    /// @dev 発行者認可取消時に発火するイベント
    event IssuerRevoked(address indexed issuer);
    
    // ========================================
    // アクセス制御修飾子
    // ========================================
    
    /**
     * @dev 管理者のみ実行可能
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute");
        _;
    }
    
    /**
     * @dev 認可された発行者のみ実行可能
     */
    modifier onlyAuthorizedIssuer() {
        require(authorizedIssuers[msg.sender], "Not authorized issuer");
        _;
    }
    
    // ========================================
    // コンストラクタ
    // ========================================
    
    /**
     * @dev コントラクト初期化
     * デプロイ者を管理者および初期発行者として設定
     */
    constructor() {
        admin = msg.sender;
        authorizedIssuers[msg.sender] = true;
    }
    
    // ========================================
    // 発行者認証・権限管理
    // ========================================
    
    /**
     * @dev 新しい発行者を認可
     * @param issuer 認可する発行者のアドレス
     */
    function authorizeIssuer(address issuer) external onlyAdmin {
        require(issuer != address(0), "Invalid issuer address");
        authorizedIssuers[issuer] = true;
        emit IssuerAuthorized(issuer);
    }
    
    /**
     * @dev 発行者の認可を取消
     * @param issuer 認可を取り消す発行者のアドレス
     */
    function revokeIssuer(address issuer) external onlyAdmin {
        require(issuer != admin, "Cannot revoke admin");
        authorizedIssuers[issuer] = false;
        emit IssuerRevoked(issuer);
    }
    
    // ========================================
    // 会員証ハッシュ値登録・管理
    // ========================================
    
    /**
     * @dev 会員証発行（画像ハッシュベース）
     * @param imageHash 処理済み画像のハッシュ値
     * @param holder 会員証保持者のアドレス
     * @param expiresAt 有効期限（UNIXタイムスタンプ）
     * @return credentialId 生成された会員証ID
     */
    function issueMembership(
        bytes32 imageHash,
        address holder,
        uint256 expiresAt
    ) external onlyAuthorizedIssuer returns (bytes32) {
        require(imageHash != bytes32(0), "Invalid image hash");
        require(holder != address(0), "Invalid holder address");
        require(expiresAt > block.timestamp, "Invalid expiration time");
        
        // ユニークな会員証IDを生成
        bytes32 credentialId = keccak256(abi.encodePacked(
            imageHash, 
            holder, 
            msg.sender, 
            block.timestamp
        ));
        
        // 重複チェック
        require(credentials[credentialId].issuedAt == 0, "Credential already exists");
        
        // 会員証情報を保存
        credentials[credentialId] = MemberCredential({
            imageHash: imageHash,
            holder: holder,
            issuer: msg.sender,
            issuedAt: block.timestamp,
            expiresAt: expiresAt,
            active: true
        });
        
        emit MembershipIssued(credentialId, holder, msg.sender);
        return credentialId;
    }
    
    // ========================================
    // 会員証検証・改ざん検出
    // ========================================
    
    /**
     * @dev 会員証認証（改ざん検出・信頼性保証）
     * @param credentialId 検証する会員証ID
     * @param imageHash 提出された画像のハッシュ値
     * @return 認証結果（true: 有効, false: 無効）
     */
    function verifyMembership(bytes32 credentialId, bytes32 imageHash) external view returns (bool) {
        MemberCredential memory cred = credentials[credentialId];
        
        // 存在チェック
        if (cred.issuedAt == 0) return false;
        
        // 有効性チェック
        if (!cred.active) return false;
        
        // 有効期限チェック
        if (block.timestamp >= cred.expiresAt) return false;
        
        // 画像ハッシュ照合（改ざん検出）
        if (cred.imageHash != imageHash) return false;
        
        return true;
    }
    
    /**
     * @dev 会員証詳細情報取得
     * @param credentialId 取得する会員証ID
     * @return 会員証情報
     */
    function getCredential(bytes32 credentialId) external view returns (MemberCredential memory) {
        require(credentials[credentialId].issuedAt > 0, "Credential does not exist");
        return credentials[credentialId];
    }
    
    // ========================================
    // 会員証失効処理
    // ========================================
    
    /**
     * @dev 会員証失効（発行者または管理者のみ実行可能）
     * @param credentialId 失効する会員証ID
     */
    function revokeMembership(bytes32 credentialId) external {
        require(credentials[credentialId].issuedAt > 0, "Credential does not exist");
        require(
            msg.sender == credentials[credentialId].issuer || msg.sender == admin, 
            "Not authorized to revoke"
        );
        
        credentials[credentialId].active = false;
        emit MembershipRevoked(credentialId);
    }
    
    // ========================================
    // ユーティリティ関数
    // ========================================
    
    /**
     * @dev 発行者認可状況確認
     * @param issuer 確認する発行者のアドレス
     * @return 認可状況（true: 認可済み, false: 未認可）
     */
    function isAuthorizedIssuer(address issuer) external view returns (bool) {
        return authorizedIssuers[issuer];
    }
    
    /**
     * @dev 会員証の有効性確認（ハッシュ照合なし）
     * @param credentialId 確認する会員証ID
     * @return 有効性（true: 有効, false: 無効）
     */
    function isCredentialActive(bytes32 credentialId) external view returns (bool) {
        MemberCredential memory cred = credentials[credentialId];
        return cred.issuedAt > 0 && cred.active && block.timestamp < cred.expiresAt;
    }
}