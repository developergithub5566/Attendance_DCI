import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Needed for Completer
import 'dart:html' as html; // Only for web (ensure this runs only on web)


class GoogleCalendarService {
  final String clientId = "794795546739-gerc0clp04h1qbg5gfphjmsjcvgq6jga.apps.googleusercontent.com";
  final String clientSecret = "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";
  final String redirectUri = "https://attendance-dci.web.app";
  final String scopes = "https://www.googleapis.com/auth/calendar.events";

  final _secureStorage = FlutterSecureStorage(); // For mobile
  // You can also use SharedPreferences for web if needed
  

   // For web, we can use SharedPreferences.
  
  // Save access token for web (using SharedPreferences)
  Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);  // Save token in SharedPreferences
    print("✅ Saved Access Token: $accessToken");
  }

  // Retrieve access token from SharedPreferences
  Future<String?> getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");

    if (token == null) {
      print("🔄 No token found, please authenticate first.");
      return null;
    }

    print("🔄 Retrieved Access Token from SharedPreferences: $token");
    return token;
  }

  // Authenticate the user and get the access token
 Future<String?> authenticateUser() async {
    final authUrl =
        "https://accounts.google.com/o/oauth2/auth"
        "?client_id=$clientId"
        "&redirect_uri=$redirectUri"
        "&response_type=code"
        "&scope=$scopes"
        "&access_type=offline"
        "&prompt=consent";

    try {
      print("🌍 Opening Google Sign-In...");

      if (kIsWeb) {
        final authWindow = html.window.open(authUrl, "_blank");

        Completer<String?> completer = Completer<String?>();

        html.window.onMessage.listen((event) async {
          if (event.data != null && event.data['authCode'] != null) {
            String authCode = event.data['authCode'];
            print("✅ Received Auth Code: $authCode");

            String? token = await getAccessToken(authCode);
            if (token != null) {
              await saveAccessToken(token);
              print("✅ Access Token Saved!");
              completer.complete(token);
            } else {
              completer.complete(null);
            }
          }
        });

        return completer.future;
      } else {
        print("❌ Google authentication is only available on the web.");
        return null;
      }
    } catch (e) {
      print("❌ Authentication failed: $e");
      return null;
    }
  }

  // Exchange auth code for access token
  Future<String?> getAccessToken(String code) async {
  final response = await http.post(
    Uri.parse("https://oauth2.googleapis.com/token"),
    body: {
      "client_id": clientId,
      "client_secret": clientSecret,
      "code": code,
      "redirect_uri": redirectUri,
      "grant_type": "authorization_code",
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    String accessToken = data['access_token'];
    await saveAccessToken(accessToken); // Save token
    print("✅ Access token saved: $accessToken");
    return accessToken;
  } else {
    print("❌ Failed to get access token: ${response.body}");
    return null;
  }
}

Future<void> updateCalendarEvent(
    String accessToken,
    String eventId,
    String title,
    DateTime start,
    DateTime end,
    List<String> attendees) async {

  final url = Uri.parse("https://www.googleapis.com/calendar/v3/calendars/primary/events/$eventId");

  final event = {
    "summary": title,
    "start": {
      "dateTime": start.toUtc().toIso8601String(),
      "timeZone": "Asia/Manila",
    },
    "end": {
      "dateTime": end.toUtc().toIso8601String(),
      "timeZone": "Asia/Manila",
    },
    "attendees": attendees.map((email) => {"email": email}).toList(),
  };

  final response = await http.put(
    url,
    headers: {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    },
    body: json.encode(event),
  );

  if (response.statusCode == 200) {
    print("✅ Event Updated Successfully!");
  } else {
    print("❌ Failed to update event: ${response.body}");
  }
}


  // Delete existing Google Calendar event
  Future<void> deleteEvent(String eventId, String accessToken) async {
  final url = Uri.parse("https://www.googleapis.com/calendar/v3/calendars/primary/events/$eventId");

  final response = await http.delete(
    url,
    headers: {
      "Authorization": "Bearer $accessToken",
    },
  );

  if (response.statusCode == 204) {
    // Event successfully deleted
    print("✅ Event deleted successfully");
  } else {
    // Handle the error
    print("❌ Failed to delete event: ${response.body}");
  }
}


  // Create Google Calendar event
  Future<String?> createCalendarEvent(
  String accessToken, 
  String title, 
  DateTime start, 
  DateTime end, 
  List<String> attendees
) async {
  final url = Uri.parse("https://www.googleapis.com/calendar/v3/calendars/primary/events");

  final event = {
    "summary": title,
    "start": {
      "dateTime": start.toUtc().toIso8601String(),
      "timeZone": "Asia/Manila",
    },
    "end": {
      "dateTime": end.toUtc().toIso8601String(),
      "timeZone": "Asia/Manila",
    },
    "attendees": attendees.map((email) => {"email": email}).toList(),
  };

  final response = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    },
    body: json.encode(event),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = json.decode(response.body);
    String eventId = data['id'];  // Extract the event ID from the response
    print("✅ Event Created Successfully with ID: $eventId");
    return eventId;  // Return the event ID
  } else {
    print("❌ Failed to create event: ${response.body}");
    return null;  // Return null if creation fails
  }
}

}