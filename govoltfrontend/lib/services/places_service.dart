import 'package:flutter/services.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  String? apiKey;

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('lib/services/api.json');
    Map<String, dynamic> jsonData = convert.jsonDecode(jsonString);
    apiKey = jsonData['apiKey'];
  }

  Future<List<PlaceSearch>> getAutoComplete(
      String search, double lat, double lng) async {
    if (apiKey == null) await loadJsonData();
    const region = "es";
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$apiKey&location=$lat%2C$lng&radius=5000&origin=$lat%2C$lng&region=$region');
    var response = await http.get(url);
    print("hola2");
    var json = convert.jsonDecode(response.body);
    /*Map<String, dynamic> json = {
      "predictions": [
        {
          "description": "Baltimore, MD, USA",
          "matched_substrings": [
            {"length": 1, "offset": 0}
          ],
          "place_id": "ChIJt4P01q4DyIkRWOcjQqiWSAQ",
          "reference": "ChIJt4P01q4DyIkRWOcjQqiWSAQ",
          "structured_formatting": {
            "main_text": "Baltimore",
            "main_text_matched_substrings": [
              {"length": 1, "offset": 0}
            ],
            "secondary_text": "MD, USA"
          },
          "terms": [
            {"offset": 0, "value": "Baltimore"},
            {"offset": 11, "value": "MD"},
            {"offset": 15, "value": "USA"}
          ],
          "types": ["locality", "political", "geocode"]
        },
        {
          "description": "Bethesda, MD, USA",
          "matched_substrings": [
            {"length": 1, "offset": 0}
          ],
          "place_id": "ChIJLQIkarfLt4kRDc0ravd5siY",
          "reference": "ChIJLQIkarfLt4kRDc0ravd5siY",
          "structured_formatting": {
            "main_text": "Bethesda",
            "main_text_matched_substrings": [
              {"length": 1, "offset": 0}
            ],
            "secondary_text": "MD, USA"
          },
          "terms": [
            {"offset": 0, "value": "Bethesda"},
            {"offset": 10, "value": "MD"},
            {"offset": 14, "value": "USA"}
          ],
          "types": ["locality", "political", "geocode"]
        },
        {
          "description": "Brambleton, VA, USA",
          "matched_substrings": [
            {"length": 1, "offset": 0}
          ],
          "place_id": "ChIJaTZp6XZAtokRxsvichIEaLI",
          "reference": "ChIJaTZp6XZAtokRxsvichIEaLI",
          "structured_formatting": {
            "main_text": "Brambleton",
            "main_text_matched_substrings": [
              {"length": 1, "offset": 0}
            ],
            "secondary_text": "VA, USA"
          },
          "terms": [
            {"offset": 0, "value": "Brambleton"},
            {"offset": 12, "value": "VA"},
            {"offset": 16, "value": "USA"}
          ],
          "types": ["locality", "political", "geocode"]
        },
        {
          "description": "Broadlands, VA, USA",
          "matched_substrings": [
            {"length": 1, "offset": 0}
          ],
          "place_id": "ChIJ81HJoqs_tokRmR1HxjHIM1U",
          "reference": "ChIJ81HJoqs_tokRmR1HxjHIM1U",
          "structured_formatting": {
            "main_text": "Broadlands",
            "main_text_matched_substrings": [
              {"length": 1, "offset": 0}
            ],
            "secondary_text": "VA, USA"
          },
          "terms": [
            {"offset": 0, "value": "Broadlands"},
            {"offset": 12, "value": "VA"},
            {"offset": 16, "value": "USA"}
          ],
          "types": ["locality", "political", "geocode"]
        },
        {
          "description": "Boston, MA, USA",
          "matched_substrings": [
            {"length": 1, "offset": 0}
          ],
          "place_id": "ChIJGzE9DS1l44kRoOhiASS_fHg",
          "reference": "ChIJGzE9DS1l44kRoOhiASS_fHg",
          "structured_formatting": {
            "main_text": "Boston",
            "main_text_matched_substrings": [
              {"length": 1, "offset": 0}
            ],
            "secondary_text": "MA, USA"
          },
          "terms": [
            {"offset": 0, "value": "Boston"},
            {"offset": 8, "value": "MA"},
            {"offset": 12, "value": "USA"}
          ],
          "types": ["locality", "political", "geocode"]
        }
      ],
      "status": "OK"
    };
    */
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    if (apiKey == null) await loadJsonData();
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    print("hola3");
    /*Map<String, dynamic> json = {
      "html_attributions": [],
      "result": {
        "address_components": [
          {
            "long_name": "Baltimore",
            "short_name": "Baltimore",
            "types": ["locality", "political"]
          },
          {
            "long_name": "Maryland",
            "short_name": "MD",
            "types": ["administrative_area_level_1", "political"]
          },
          {
            "long_name": "United States",
            "short_name": "US",
            "types": ["country", "political"]
          }
        ],
        "adr_address":
            "\u003cspan class=\"locality\"\u003eBaltimore\u003c/span\u003e, \u003cspan class=\"region\"\u003eMD\u003c/span\u003e, \u003cspan class=\"country-name\"\u003eUSA\u003c/span\u003e",
        "formatted_address": "Baltimore, MD, USA",
        "geometry": {
          "location": {"lat": 39.2903848, "lng": -76.6121893},
          "viewport": {
            "northeast": {"lat": 39.37220594411627, "lng": -76.52945281200961},
            "southwest": {"lat": 39.19720691882772, "lng": -76.71154072046406}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/generic_pinlet",
        "name": "Baltimore",
        "photos": [
          {
            "height": 3024,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/105453448070897359356\"\u003eJonathan Segal\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuHHb-G2gVEaO57yKjq56Jz4z8_F7YikXevN-emN9L4ekUMactqIb5r2AIBxYZAsV8Eaye4q_35hqWtr-49S984WDeOExhRiYvliIK3wVBfbFXrMy6vtSbf6WNH6fvt5BwH7S9KlXP0xs4qDmCfyc8UNMv7R32OLnZqjS6kcNbMJMM8i",
            "width": 4032
          },
          {
            "height": 2338,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/117816870074446094528\"\u003eTroy Bell\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuGrZBoYMjtAzXzciuo7Pg_vDs8Sc5ex0OoxnyC_muT1SR2rqbOXXnUmtWUKWOM0NeH51nZAjwjI5esM3bsAN3gT9uav1E3r1ZpIO2aLMx7VAoXkLNA9swlJp6B5iJEMirSiqGJNFcs4J5h0gNlsGYXq2-3Th3AlCRsXcN5jYeySV5HE",
            "width": 4608
          },
          {
            "height": 835,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/116972326442810484623\"\u003eMoises Almosny\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuF_DfWD8B6pVaZqK-6xuGEsY0PMejRaVXByiZDl8lhXBh54RWImx-hZ9ANusi7VeFtYJ-h3QlXowr3fpK0ns818dNmV1PzVxL8A_nh44sE8ieUUKMcTGcBH7deMvuNaWHbUwZiKfnSqVCtVP2i1mjfbamozcWvdu74zUhloKKIR09lS",
            "width": 1125
          },
          {
            "height": 2340,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/117544549864735758700\"\u003eAmaris Morales\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuEPWXhSVWfG1IJl6glJecqDl_geTTa_zpZD7vGBnxzkd1XcTzOfIHp2Gjgh34p5EnSusTYG9WoDg4jVpoyYPIpMcDeFfCafHCxXEcEXKF2e5oaxU_D0VQ_DEgjn8x0aHXZT0fAQCSZ5QxYTxXDD-Fat6ls0MMnTYfbdIAWalkt6cyFP",
            "width": 4160
          },
          {
            "height": 3024,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/110235052831689832540\"\u003eChaim Bin-Nun\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuFUlSuDkOFpkbwmBOZ-qRyvCKDL2eEwNwhqR3giqRRLQuAR1JQKAeBB1IqSlstPeBdMe3E2jAUEt7MfLEE7OsSD069zR5hdsTkAt4ZWVVIrTiWKGulPLIeIdA3x7xPExyBcGUExQqFICvWv6F-p66ZOqLWpIqIywVkqhoquEEuWxjwx",
            "width": 4032
          },
          {
            "height": 4032,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/113148267549440363760\"\u003eMohammad mousavi sani\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuEJUbPxWYqM_ehEbXU8EFw6uD1SHYi2mG0dn2qw3oQSaT5R80YLoOkXAFzwmKs6ILdeugRuSrHnDTJ9b5O7s-DKUy8FMPcXpc31JUn1Eveud2tINCK6VodIQPku9nS7fdq8V-qFNi8ZY4vEwHztOcJvyaEIQcz9Xjl7a_lkgWYLpNbH",
            "width": 3024
          },
          {
            "height": 1080,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/105453448070897359356\"\u003eJonathan Segal\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuHSOlPLUbSGj_THQn0VtUvjGuh1-afdzekqJs3UaZ0FhjJQYvKghxLINEqhPGn_Ly93mQvtiD1LMypgY6Iy0Mk9bc_tubpAfpt_vaiw8yFm6gTlBvoo3uY0EUoRfoCotSZG-MeWFKyVf3zXa4O_fsYfgxGovluk7nW6N9U6LNOFdl5L",
            "width": 1619
          },
          {
            "height": 3024,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/114010919886140778204\"\u003eEric Kanowitz\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuFU0o7jLANZ_cg2mR1pYXMz1wechPXDqfEoeZnxWEre2FXRLgOgDo7W-aVfJxSbbGSAiUL9ZtPhpTUjLuTBUAnRtcYoSguYqj9y4EsAsMo8bNhHy8zvIQqIywiY00rSl-K8-GLppkF1Nv26XqV2SZEJiQdrngox3zwY8Oo476Uatw0J",
            "width": 4032
          },
          {
            "height": 3464,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/117009549969150833349\"\u003eKaren Falvey\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuH_oVc061vGzHyDck-WIompY99dg7VVhHYRVb_6-GJMEHqQIx05llSF7DaDZQIcv35lt66Gs6_L44wy_oAWm4YVFeNRvAmG-IoIoPTCAHDojn3BDks13_R0htrFYes8jIQG7an0rch4hm8rY5ZnMSEhz-MKDJfcaCdR_n7XlhWYcsdv",
            "width": 4618
          },
          {
            "height": 1080,
            "html_attributions": [
              "\u003ca href=\"https://maps.google.com/maps/contrib/105453448070897359356\"\u003eJonathan Segal\u003c/a\u003e"
            ],
            "photo_reference":
                "AcJnMuHPJMIYDu-GtavZjNPKscwsjKUrV-gske_h5dAKx392gP-8lFoppEIeuu7puro-olq9L62g6ok7O8F8xDObRg3Vrqx6mPaEB9CxQIAZT453FOYhxqZLmZls1N0dRHNH1xxqHeHb0bES9Uq4nURpOWozf6BzSbZ18ExeU3xxcn9OAbDa",
            "width": 1619
          }
        ],
        "place_id": "ChIJt4P01q4DyIkRWOcjQqiWSAQ",
        "reference": "ChIJt4P01q4DyIkRWOcjQqiWSAQ",
        "types": ["locality", "political"],
        "url":
            "https://maps.google.com/?q=Baltimore,+MD,+USA&ftid=0x89c803aed6f483b7:0x44896a84223e758",
        "utc_offset": -240,
        "vicinity": "Baltimore",
        "website": "http://www.baltimorecity.gov/"
      },
      "status": "OK"
    };

    */
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }
}
