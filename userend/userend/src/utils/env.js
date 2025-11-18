export const isPommaDeployment = () => {
  if (typeof window === "undefined") {
    return false;
  }
  const path = window.location.pathname || "";
  return path.startsWith("/pommaholidays") || path.startsWith("/pommaadmin");
};

export const isOrchidDeployment = () => {
  if (typeof window === "undefined") {
    return false;
  }
  const path = window.location.pathname || "";
  return path.startsWith("/orchid") || path.startsWith("/orchidadmin");
};

export const getMediaBaseUrl = () => {
  // For local development (localhost or 127.0.0.1), always use port 8000
  if (typeof window !== "undefined") {
    const hostname = window.location.hostname || "";
    if (hostname === "localhost" || hostname === "127.0.0.1") {
      return "http://localhost:8000";
    }
  }
  
  // For production deployments
  if (typeof window !== "undefined" && isOrchidDeployment()) {
    return `${window.location.origin}/orchidfiles`;
  }
  if (typeof window !== "undefined" && isPommaDeployment()) {
    return `${window.location.origin}/pomma`;
  }
  if (process.env.REACT_APP_MEDIA_BASE_URL) {
    return process.env.REACT_APP_MEDIA_BASE_URL;
  }
  return process.env.NODE_ENV === "production"
    ? "https://www.teqmates.com"
    : "http://localhost:8000";
};

export const getApiBaseUrl = () => {
  // For local development (localhost or 127.0.0.1), always use port 8000
  if (typeof window !== "undefined") {
    const hostname = window.location.hostname || "";
    if (hostname === "localhost" || hostname === "127.0.0.1") {
      return "http://localhost:8000/api";
    }
  }
  
  // For production deployments
  if (typeof window !== "undefined" && isOrchidDeployment()) {
    return `${window.location.origin}/orchidapi/api`;
  }
  if (typeof window !== "undefined" && isPommaDeployment()) {
    return `${window.location.origin}/pommaapi/api`;
  }
  if (process.env.REACT_APP_API_BASE_URL) {
    return process.env.REACT_APP_API_BASE_URL;
  }
  return process.env.NODE_ENV === "production"
    ? "https://www.teqmates.com/api"
    : "http://localhost:8000/api";
};
