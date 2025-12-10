"""
pii_sanitizer.py - OpenAI送信前のPII除去モジュール

OpenAI APIへ送信する前に、個人識別情報（PII）を除去またはマスクする。
- ユーザーID: ソルト付きハッシュで匿名化
- メールアドレス/電話番号: マスク
- 遺伝子データ: SNP rs番号を除去し、影響スコアのみ保持
"""

import hashlib
import re
import os
from typing import Any, Dict, List, Optional


class PIISanitizer:
    """OpenAI API送信前のPII（個人識別情報）除去"""

    # 除去対象のPIIパターン
    PII_PATTERNS = [
        (r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', '[EMAIL]'),
        (r'\b0\d{1,4}[-−]?\d{1,4}[-−]?\d{4}\b', '[PHONE]'),
        (r'\b\d{3}[-−]?\d{4}[-−]?\d{4}\b', '[ID]'),
        (r'\b\d{4}[-/]\d{1,2}[-/]\d{1,2}\b', '[DATE]'),
        # SNP rs番号パターン（遺伝子データ用）
        (r'\brs\d+\b', '[SNP]'),
    ]

    @staticmethod
    def get_salt() -> str:
        """環境変数からソルトを取得（必須）"""
        salt = os.environ.get('PII_SALT')
        if not salt:
            raise ValueError(
                "PII_SALT environment variable is required. "
                "Set it in Lambda configuration."
            )
        return salt

    @classmethod
    def anonymize_user_id(cls, user_id: str) -> str:
        """
        ユーザーIDをソルト付きハッシュで匿名トークンに変換

        重要: ソルトなしハッシュは禁止（レインボーテーブル攻撃対策）
        """
        if not user_id:
            return "anonymous"

        salt = cls.get_salt()
        salted_id = f"{salt}:{user_id}"
        return f"user_{hashlib.sha256(salted_id.encode()).hexdigest()[:12]}"

    @staticmethod
    def sanitize_text(text: str) -> str:
        """テキストからPIIパターンを除去"""
        if not text:
            return ""
        result = text
        for pattern, replacement in PIISanitizer.PII_PATTERNS:
            result = re.sub(pattern, replacement, result, flags=re.IGNORECASE)
        return result

    @staticmethod
    def sanitize_blood_data(blood_data: List[Dict]) -> List[Dict]:
        """
        血液データから個人特定情報を除去

        保持する情報:
        - 項目名（nameJp）
        - 数値（value）
        - 単位（unit）
        - ステータス（status）
        - 基準値（reference）

        除去する情報:
        - key（内部識別子）
        """
        if not blood_data:
            return []
        return [
            {
                "name": item.get("nameJp", item.get("name", "")),
                "value": item.get("value", ""),
                "unit": item.get("unit", ""),
                "status": item.get("status", ""),
                "reference": item.get("reference", "")
            }
            for item in blood_data
        ]

    @staticmethod
    def sanitize_gene_data(gene_data: Dict) -> Dict:
        """
        遺伝子データからSNP rs番号を完全除去し、影響スコアのみ保持

        保持する情報:
        - カテゴリー名
        - マーカータイトル
        - 影響スコア（score, scoreLevel）
        - 保護/リスク因子数（概数のみ）

        除去する情報:
        - SNP rs番号（例: rs1234567）
        - 遺伝子型（genotypes）
        """
        if not gene_data:
            return {}

        sanitized = {}

        for category, data in gene_data.items():
            # availableCategories は除外
            if category == 'availableCategories':
                continue

            if isinstance(data, list):
                # マーカーの配列
                sanitized[category] = [
                    {
                        "title": marker.get("title", ""),
                        "impact_level": marker.get("impact", {}).get("score", 0) if isinstance(marker.get("impact"), dict) else 0,
                        "score_level": marker.get("scoreLevel", marker.get("impact", {}).get("scoreLevel", "") if isinstance(marker.get("impact"), dict) else "")
                    }
                    for marker in data
                ]
            elif isinstance(data, dict):
                # 単一マーカー
                sanitized[category] = {
                    "title": data.get("title", ""),
                    "impact_level": data.get("impact", {}).get("score", 0) if isinstance(data.get("impact"), dict) else data.get("score", 0),
                    "score_level": data.get("scoreLevel", "")
                }

        return sanitized

    @staticmethod
    def sanitize_vital_data(vital_data: Dict) -> Dict:
        """
        バイタルデータを相対的な健康状態に変換

        保持する情報:
        - 数値データ（体重、心拍数など）は一般化
        - 有無のフラグのみ

        除去する情報:
        - 絶対値（個人特定の可能性あり）
        """
        if not vital_data:
            return {}

        # 相対的な指標のみを保持
        return {
            "has_body_composition": bool(vital_data.get("bodyMass")),
            "has_heart_data": bool(vital_data.get("restingHeartRate") or vital_data.get("heartRateVariability")),
            "has_activity_data": bool(vital_data.get("stepCount") or vital_data.get("activeEnergyBurned")),
            "has_vo2max": bool(vital_data.get("vo2Max")),
            "vo2max_level": "high" if (vital_data.get("vo2Max") or 0) > 45 else "moderate" if (vital_data.get("vo2Max") or 0) > 35 else "low" if vital_data.get("vo2Max") else None,
            "resting_hr_level": "athlete" if (vital_data.get("restingHeartRate") or 100) < 55 else "good" if (vital_data.get("restingHeartRate") or 100) < 70 else "average"
        }

    @staticmethod
    def sanitize_conversation_history(history: List[Dict]) -> List[Dict]:
        """会話履歴からPIIを除去"""
        if not history:
            return []
        return [
            {
                "role": msg.get("role", ""),
                "content": PIISanitizer.sanitize_text(msg.get("content", ""))
            }
            for msg in history
        ]

    @classmethod
    def sanitize_request(cls, request_data: Dict) -> Dict:
        """OpenAI送信前の統合サニタイズ処理"""
        sanitized = {
            "user_token": cls.anonymize_user_id(request_data.get("userId", "")),
            "message": cls.sanitize_text(request_data.get("message", "")),
            "topic": request_data.get("topic", "general_health")
        }

        if "bloodData" in request_data and request_data["bloodData"]:
            sanitized["bloodData"] = cls.sanitize_blood_data(request_data["bloodData"])

        if "geneData" in request_data and request_data["geneData"]:
            sanitized["geneData"] = cls.sanitize_gene_data(request_data["geneData"])

        if "vitalData" in request_data and request_data["vitalData"]:
            sanitized["vitalData"] = cls.sanitize_vital_data(request_data["vitalData"])

        if "conversationHistory" in request_data and request_data["conversationHistory"]:
            sanitized["conversationHistory"] = cls.sanitize_conversation_history(
                request_data["conversationHistory"]
            )

        return sanitized


def sanitize_for_openai(body: Dict) -> Dict:
    """
    便利関数: Lambda handlerから直接呼び出し可能

    Args:
        body: リクエストボディ

    Returns:
        サニタイズ済みデータ

    Raises:
        ValueError: PII_SALT環境変数が設定されていない場合
    """
    return PIISanitizer.sanitize_request(body)
