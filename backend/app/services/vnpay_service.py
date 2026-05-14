import hashlib
import hmac
import urllib.parse
from datetime import datetime
from typing import Dict

class VNPay:
    def __init__(self, tmn_code: str, hash_secret: str, payment_url: str, return_url: str):
        self.vnp_TmnCode = tmn_code
        self.vnp_HashSecret = hash_secret
        self.vnp_Url = payment_url
        self.vnp_ReturnUrl = return_url
        self.responseData = {}

    def get_payment_url(self, params: Dict[str, str]) -> str:
        inputData = sorted(params.items())
        queryString = ''
        seq = 0
        for key, val in inputData:
            if str(val) != '':
                if seq == 1:
                    queryString = queryString + "&" + key + '=' + urllib.parse.quote_plus(str(val))
                else:
                    seq = 1
                    queryString = key + '=' + urllib.parse.quote_plus(str(val))

        hashValue = self.__hmacsha512(self.vnp_HashSecret, queryString)
        return self.vnp_Url + "?" + queryString + '&vnp_SecureHash=' + hashValue

    def validate_response(self, vnp_SecureHash: str) -> bool:
        hasData = ''
        seq = 0
        inputData = sorted(self.responseData.items())
        for key, val in inputData:
            if str(val) != '' and str(key).startswith('vnp_'):
                if str(key) != 'vnp_SecureHashType' and str(key) != 'vnp_SecureHash':
                    if seq == 1:
                        hasData = hasData + "&" + str(key) + '=' + urllib.parse.quote_plus(str(val))
                    else:
                        seq = 1
                        hasData = str(key) + '=' + urllib.parse.quote_plus(str(val))
        hashValue = self.__hmacsha512(self.vnp_HashSecret, hasData)
        return vnp_SecureHash == hashValue

    @staticmethod
    def __hmacsha512(key: str, data: str) -> str:
        byteKey = key.encode('utf-8')
        byteData = data.encode('utf-8')
        return hmac.new(byteKey, byteData, hashlib.sha512).hexdigest()
