const TOKEN_KEYS = {
  accessToken: "access-token",
  client: "client",
  uid: "uid",
} as const;

export interface AuthHeaders {
  "access-token": string;
  client: string;
  uid: string;
}

export const authService = {
  getHeaders(): Partial<AuthHeaders> {
    if (typeof window === "undefined") return {};
    const accessToken = localStorage.getItem(TOKEN_KEYS.accessToken);
    const client = localStorage.getItem(TOKEN_KEYS.client);
    const uid = localStorage.getItem(TOKEN_KEYS.uid);
    if (!accessToken || !client || !uid) return {};
    return { "access-token": accessToken, client, uid };
  },

  saveHeaders(headers: Record<string, string>): void {
    const accessToken = headers["access-token"];
    const client = headers["client"];
    const uid = headers["uid"];
    if (accessToken) localStorage.setItem(TOKEN_KEYS.accessToken, accessToken);
    if (client) localStorage.setItem(TOKEN_KEYS.client, client);
    if (uid) localStorage.setItem(TOKEN_KEYS.uid, uid);
  },

  clearHeaders(): void {
    localStorage.removeItem(TOKEN_KEYS.accessToken);
    localStorage.removeItem(TOKEN_KEYS.client);
    localStorage.removeItem(TOKEN_KEYS.uid);
  },

  isAuthenticated(): boolean {
    if (typeof window === "undefined") return false;
    return !!localStorage.getItem(TOKEN_KEYS.accessToken);
  },
};
