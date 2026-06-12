const functions = require("firebase-functions");
const axios = require("axios");
const cors = require("cors")({ origin: true });

// Güvenli Backend: API Key mobil uygulamada görünmeyecek, 
// sadece backend sunucusunda çalışacak.
const MAPS_API_KEY = "AIzaSyAgBG8RFM4qpV9UoP6fGynrikC-4_Sfrxo";

exports.getNearbyPlaces = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { location, radius, type, keyword, maxprice, language } = req.query;

      const response = await axios.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json", {
        params: {
          location,
          radius,
          type,
          keyword,
          maxprice,
          language: language || "tr",
          key: MAPS_API_KEY,
        },
      });

      res.status(200).json(response.data);
    } catch (error) {
      console.error("Maps API Error:", error.message);
      res.status(500).json({ error: "Internal Server Error" });
    }
  });
});

exports.getPlaceDetails = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { place_id, fields, language } = req.query;

      const response = await axios.get("https://maps.googleapis.com/maps/api/place/details/json", {
        params: {
          place_id,
          fields,
          language: language || "tr",
          key: MAPS_API_KEY,
        },
      });

      res.status(200).json(response.data);
    } catch (error) {
      console.error("Maps API Error:", error.message);
      res.status(500).json({ error: "Internal Server Error" });
    }
  });
});

exports.getDistanceMatrix = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { origins, destinations, mode, language } = req.query;

      const response = await axios.get("https://maps.googleapis.com/maps/api/distancematrix/json", {
        params: {
          origins,
          destinations,
          mode: mode || "walking",
          language: language || "tr",
          key: MAPS_API_KEY,
        },
      });

      res.status(200).json(response.data);
    } catch (error) {
      console.error("Maps API Error:", error.message);
      res.status(500).json({ error: "Internal Server Error" });
    }
  });
});

exports.getGeocode = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { latlng, language } = req.query;

      const response = await axios.get("https://maps.googleapis.com/maps/api/geocode/json", {
        params: {
          latlng,
          language: language || "tr",
          key: MAPS_API_KEY,
        },
      });

      res.status(200).json(response.data);
    } catch (error) {
      console.error("Maps API Error:", error.message);
      res.status(500).json({ error: "Internal Server Error" });
    }
  });
});

exports.getPhoto = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { maxwidth, photo_reference } = req.query;

      const response = await axios.get("https://maps.googleapis.com/maps/api/place/photo", {
        params: {
          maxwidth,
          photo_reference,
          key: MAPS_API_KEY,
        },
        responseType: "stream",
      });

      res.setHeader("Content-Type", response.headers["content-type"]);
      response.data.pipe(res);
    } catch (error) {
      console.error("Maps API Error:", error.message);
      res.status(500).send("Error fetching image");
    }
  });
});
