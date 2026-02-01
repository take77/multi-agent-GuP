import axios from "axios";
import { authService } from "@/services/authService";

const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:4001",
  headers: {
    "Content-Type": "application/json",
  },
});

// リクエスト: 認証ヘッダー自動付与
apiClient.interceptors.request.use((config) => {
  const headers = authService.getHeaders();
  Object.entries(headers).forEach(([key, value]) => {
    if (value) config.headers.set(key, value);
  });
  return config;
});

// レスポンス: トークン更新を自動保存
apiClient.interceptors.response.use(
  (response) => {
    const headers = response.headers as Record<string, string>;
    if (headers["access-token"]) {
      authService.saveHeaders(headers);
    }
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      authService.clearHeaders();
    }
    return Promise.reject(error);
  },
);

export default apiClient;
