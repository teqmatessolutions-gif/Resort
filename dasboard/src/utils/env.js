export const isResortDeployment = () => {
  if (typeof window === "undefined") {
    return false;
  }
  const path = window.location.pathname || "";
  return path.startsWith("/admin") || path.startsWith("/resort");
};

export const getMediaBaseUrl = () => {
  // For local development, always use localhost:8012
  if (process.env.NODE_ENV !== "production") {
    return "http://localhost:8012";
  }
  if (typeof window !== "undefined" && isResortDeployment()) {
    return `${window.location.origin}/resort`;
  }
  if (process.env.REACT_APP_MEDIA_BASE_URL) {
    return process.env.REACT_APP_MEDIA_BASE_URL;
  }
  return "https://www.teqmates.com";
};

export const getApiBaseUrl = () => {
  // For local development, always use localhost:8012
  if (process.env.NODE_ENV !== "production") {
    return "http://localhost:8012/api";
  }
  // Prefer explicit env override in production
  if (process.env.REACT_APP_API_BASE_URL) {
    return process.env.REACT_APP_API_BASE_URL;
  }
  // For assets served under /admin or /resort in production,
  // build absolute API path off the current origin.
  if (typeof window !== "undefined" && isResortDeployment()) {
    return `${window.location.origin}/resoapi/api`;
  }
  // Sensible defaults
  return "https://teqmates.com/resoapi/api";
};
