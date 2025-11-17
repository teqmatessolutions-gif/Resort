export const isPommaDeployment = () => {
  if (typeof window === "undefined") {
    return false;
  }
  const path = window.location.pathname || "";
  return path.startsWith("/pommaadmin") || path.startsWith("/pommaholidays");
};

export const isOrchidDeployment = () => {
  if (typeof window === "undefined") {
    return false;
  }
  const path = window.location.pathname || "";
  return path.startsWith("/orchidadmin") || path.startsWith("/orchid");
};

export const getMediaBaseUrl = () => {
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
  // Prefer explicit env override in all environments (dev/prod)
  if (process.env.REACT_APP_API_BASE_URL) {
    return process.env.REACT_APP_API_BASE_URL;
  }
  // For assets served under /orchidadmin or /orchid in production,
  // build absolute API path off the current origin.
  if (typeof window !== "undefined" && isOrchidDeployment()) {
    return `${window.location.origin}/orchidapi/api`;
  }
  // For assets served under /pommaadmin or /pommaholidays in production,
  // build absolute API path off the current origin.
  if (typeof window !== "undefined" && isPommaDeployment()) {
    return `${window.location.origin}/pommaapi/api`;
  }
  // Sensible defaults
  return process.env.NODE_ENV === "production"
    ? "https://www.teqmates.com/orchidapi/api"
    : "http://127.0.0.1:8000/api";
};
