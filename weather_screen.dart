// test/weather_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// Replace 'your_app_name' with your actual project name in the imports below
import 'package:your_app_name/models/weather.dart';
import 'package:your_app_name/screens/weather_screen.dart';
import 'package:your_app_name/services/weather_service.dart';

// Import the generated mocks file
import 'mocks.mocks.dart';

void main() {
  // Declare the mock service instance
  late MockWeatherService mockWeatherService;

  // Define realistic sample data for London (initial load) and Manila (search)
  final londonWeather = Weather(
    city: 'London',
    temperature: 15.0,
    description: 'scattered clouds',
    humidity: 82,
    windSpeed: 4.63,
  );

  final manilaWeather = Weather(
    city: 'Manila',
    temperature: 31.5,
    description: 'broken clouds',
    humidity: 74,
    windSpeed: 3.09,
  );

  // This setup function runs before each test, ensuring a clean state
  setUp(() {
    mockWeatherService = MockWeatherService();
    // We replace the static singleton instance with our mock
    WeatherService.instance = mockWeatherService;
  });

  // A helper function to create and render the WeatherScreen widget
  Future<void> pumpWeatherScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WeatherScreen(),
    ));
  }

  group('WeatherScreen Widget Tests', () {
    // Test 1: Verify the initial loading and display of default weather (London)
    testWidgets('should show loading indicator and then display initial weather for London', (WidgetTester tester) async {
      // ARRANGE: Set up the mock to return London's weather
      when(mockWeatherService.fetchWeather('London'))
          .thenAnswer((_) async => londonWeather);

      // ACT: Render the screen
      await pumpWeatherScreen(tester);

      // ASSERT 1: Verify the loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // ACT 2: Wait for the Future to complete and the UI to rebuild
      await tester.pumpAndSettle();

      // ASSERT 2: Verify the weather data for London is displayed
      expect(find.text('London'), findsOneWidget);
      expect(find.text('15.0°C'), findsOneWidget);
      expect(find.text('scattered clouds'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('Wind Speed'), findsOneWidget);
      expect(find.text('4.6 m/s'), findsOneWidget);
    });

    // Test 2: Verify searching for a new city (Manila)
    testWidgets('should fetch and display weather for a searched city', (WidgetTester tester) async {
      // ARRANGE: Mock both London (initial) and Manila (search) calls
      when(mockWeatherService.fetchWeather('London'))
          .thenAnswer((_) async => londonWeather);
      when(mockWeatherService.fetchWeather('Manila'))
          .thenAnswer((_) async => manilaWeather);

      // ACT 1: Render the screen and wait for the initial build to finish
      await pumpWeatherScreen(tester);
      await tester.pumpAndSettle();

      // ACT 2: Simulate user input by entering 'Manila' into the TextField
      await tester.enterText(find.byType(TextField), 'Manila');

      // ACT 3: Simulate tapping the search button
      await tester.tap(find.byIcon(Icons.search));

      // ACT 4: Let the loading state render
      await tester.pump();

      // ASSERT 1: Verify the loading indicator appears again after searching
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // ACT 5: Wait for the new weather data to arrive and UI to settle
      await tester.pumpAndSettle();

      // ASSERT 2: Verify the UI now displays Manila's weather data
      expect(find.text('Manila'), findsOneWidget);
      expect(find.text('31.5°C'), findsOneWidget);
      expect(find.text('broken clouds'), findsOneWidget);
      expect(find.text('74%'), findsOneWidget); // Humidity for Manila
    });

    // Test 3: Verify error handling UI
    testWidgets('should display an error message when fetching weather fails', (WidgetTester tester) async {
      // ARRANGE: Set up the mock to throw an exception
      final errorMessage = 'City not found';
      when(mockWeatherService.fetchWeather('London'))
          .thenThrow(Exception(errorMessage));

      // ACT: Render the screen and wait for the future to complete
      await pumpWeatherScreen(tester);
      await tester.pumpAndSettle();

      // ASSERT: Verify the error icon and message are displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Test 4: Verify input validation for empty search
    testWidgets('should show a SnackBar if search is attempted with an empty city', (WidgetTester tester) async {
      // ARRANGE: Mock the initial London call
      when(mockWeatherService.fetchWeather('London'))
          .thenAnswer((_) async => londonWeather);

      // ACT: Render the screen and wait for it to settle
      await pumpWeatherScreen(tester);
      await tester.pumpAndSettle();

      // ACT 2: Tap the search button without entering any text
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump(); // pump to show the SnackBar

      // ASSERT: Verify the SnackBar is displayed with the correct message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter a city name'), findsOneWidget);
    });
  });
}
