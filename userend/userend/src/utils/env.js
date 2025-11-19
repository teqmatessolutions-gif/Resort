export const isResortDeployment = () => {
  if (typeof window === "undefined") {
    return false;
  }
  const path = window.location.pathname || "";
  return path.startsWith("/resort") || path.startsWith("/admin");
};

export const getMediaBaseUrl = () => {
  // For local development, always use localhost:8012
  if (process.env.NODE_ENV !== "production") {
    return "http://localhost:8012";
  }
  if (typeof window !== "undefined" && isResortDeployment()) {
    return `${window.location.origin}/resortfiles`;
  }
  if (process.env.REACT_APP_MEDIA_BASE_URL) {
    return process.env.REACT_APP_MEDIA_BASE_URL;
  }
  return "https://teqmates.com";
};

export const getApiBaseUrl = () => {
  // For local development, always use localhost:8012
  if (process.env.NODE_ENV !== "production") {
    return "http://localhost:8012/api";
  }
  if (typeof window !== "undefined" && isResortDeployment()) {
    return `${window.location.origin}/resoapi/api`;
  }
  if (process.env.REACT_APP_API_BASE_URL) {
    return process.env.REACT_APP_API_BASE_URL;
  }
  return "https://teqmates.com/resoapi/api";
};
