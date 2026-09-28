const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");

const mapsServerKey = defineSecret("GOOGLE_MAPS_SERVER_KEY");

function validPoint(value) {
  if (!value || typeof value !== "object") return false;
  const lat = Number(value.lat);
  const lng = Number(value.lng);
  return Number.isFinite(lat) && Number.isFinite(lng) &&
    lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

exports.calculateRoadRoute = onCall(
  {
    region: "asia-south1",
    secrets: [mapsServerKey],
    timeoutSeconds: 20,
    memory: "256MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in before calculating a route.");
    }
    const pickup = request.data && request.data.pickup;
    const destination = request.data && request.data.destination;
    if (!validPoint(pickup) || !validPoint(destination)) {
      throw new HttpsError("invalid-argument", "Valid pickup and destination pins are required.");
    }

    const response = await fetch("https://routes.googleapis.com/directions/v2:computeRoutes", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": mapsServerKey.value(),
        "X-Goog-FieldMask": "routes.distanceMeters,routes.duration",
      },
      body: JSON.stringify({
        origin: {location: {latLng: {latitude: Number(pickup.lat), longitude: Number(pickup.lng)}}},
        destination: {location: {latLng: {latitude: Number(destination.lat), longitude: Number(destination.lng)}}},
        travelMode: "DRIVE",
        routingPreference: "TRAFFIC_UNAWARE",
        computeAlternativeRoutes: false,
        languageCode: "en-IN",
        units: "METRIC",
      }),
    });

    const data = await response.json();
    if (!response.ok) {
      console.error("Google Routes API failure", response.status, data && data.error && data.error.status);
      throw new HttpsError("unavailable", "Road distance is temporarily unavailable.");
    }
    const route = Array.isArray(data.routes) ? data.routes[0] : null;
    const distanceMeters = Number(route && route.distanceMeters);
    if (!Number.isFinite(distanceMeters) || distanceMeters <= 0) {
      throw new HttpsError("not-found", "No drivable route was found between the selected pins.");
    }
    return {
      distanceKm: Math.round((distanceMeters / 1000) * 10) / 10,
      duration: route.duration || null,
    };
  },
);
