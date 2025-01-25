import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'hourly_forecast_card.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double currentTemp = -1000.0;
  String currentSky = 'NULL';
  int currentHumidity = 0;
  double currentWindSpeed = 0;
  int currentPressure = 0;
  dynamic weatherData;
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future getCurrentWeather() async {
    try {
      String cityName = 'Silchar';
      await dotenv.load(fileName: '.env');
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=${dotenv.env['OPENWEATHERAPIKEY']}',
        ),
      );
      final data = jsonDecode(result.body);
      weatherData = data;
      if (data['cod'] != '200') {
        throw "An Unexpected error occurred\n";
      }
      setState(() {
        currentTemp = data['list'][0]['main']['temp'];
        currentSky = data['list'][0]['weather'][0]['main'];
        currentHumidity = data['list'][0]['main']['humidity'];
        currentWindSpeed = data['list'][0]['wind']['speed'];
        currentPressure = data['list'][0]['main']['pressure'];
      });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WeatherMate",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        toolbarHeight: 30,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: currentTemp == -1000
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Placeholder(
                    //   fallbackHeight: 250,
                    // ),
                    // Main Card
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    "${(currentTemp - 273.15).toStringAsFixed(2)}° C",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 32,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Icon(
                                    currentSky == 'Clear'
                                        ? int.parse(weatherData['list'][0]
                                                        ['dt_txt']
                                                    .toString()
                                                    .substring(11, 13)) >=
                                                18
                                            ? WeatherIcons.day_sunny
                                            : WeatherIcons.night_clear
                                        : currentSky == 'Clouds'
                                            ? WeatherIcons.cloud
                                            : currentSky == 'Rain'
                                                ? WeatherIcons.rain
                                                : currentSky == 'Snow'
                                                    ? WeatherIcons.snow
                                                    : currentSky ==
                                                            'Thunderstorm'
                                                        ? WeatherIcons
                                                            .thunderstorm
                                                        : WeatherIcons.alien,
                                    size: 60,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    currentSky,
                                    style: TextStyle(
                                      fontSize: 19,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Weather Forecast :",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 1; i <= 20; i++)
                            HourlyForecastItem(
                              time: DateFormat.j().format(DateTime.parse(
                                  weatherData['list'][i]['dt_txt'])),
                              icon: weatherData['list'][i]['weather'][0]['main'] ==
                                      'Clear'
                                  ? (int.parse(weatherData['list'][i]['dt_txt'].toString().substring(11, 13)) < 18 &&
                                          int.parse(weatherData['list'][i]['dt_txt']
                                                  .toString()
                                                  .substring(11, 13)) >=
                                              6)
                                      ? WeatherIcons.day_sunny
                                      : WeatherIcons.night_clear
                                  : weatherData['list'][i]['weather'][0]['main'] ==
                                          'Clouds'
                                      ? WeatherIcons.cloud
                                      : weatherData['list'][i]['weather'][0]['main'] ==
                                              'Rain'
                                          ? WeatherIcons.rain
                                          : weatherData['list'][i]['weather'][0]['main'] ==
                                                  'Snow'
                                              ? WeatherIcons.snow
                                              : weatherData['list'][i]['weather']
                                                          [0]['main'] ==
                                                      'Thunderstorm'
                                                  ? WeatherIcons.thunderstorm
                                                  : WeatherIcons.alien,
                              temperature: (weatherData['list'][i]['main']
                                              ['temp'] -
                                          273.15)
                                      .toStringAsFixed(2) +
                                  "° C",
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "More Insights : ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Additional Information
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      spacing: 18,
                      children: [
                        Card(
                          child: Container(
                            width: 100,
                            color: Theme.of(context).colorScheme.surface,
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  "Humidity",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  "$currentHumidity",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          child: Container(
                            width: 100,
                            color: Theme.of(context).colorScheme.surface,
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.air_sharp,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  "Wind Speed",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  "$currentWindSpeed",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          child: Container(
                            width: 100,
                            color: Theme.of(context).colorScheme.surface,
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.speed,
                                  size: 28,
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  "Pressure",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  "$currentPressure",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}