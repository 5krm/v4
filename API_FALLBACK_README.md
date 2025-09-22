# API Fallback System

This VPN app now includes an automatic API fallback system that ensures connectivity even when the primary API server is unavailable.

## How It Works

### Primary and Fallback URLs
- **Primary URL**: `https://eclipse.anfaan.com/public/`
- **Fallback URL**: `https://eclipse.anfaan.com/`

### Automatic Switching
The system automatically:
1. **Detects failures** when the primary URL is unreachable
2. **Tests the fallback URL** and switches if it's available
3. **Retries failed requests** using the fallback URL
4. **Periodically checks** (every 5 minutes) if the primary URL is back online
5. **Automatically switches back** to the primary URL when it becomes available

## Implementation Details

### Core Components

1. **MyHelper Class** (`lib/utils/my_helper.dart`)
   - Manages URL switching logic
   - Tests URL connectivity
   - Provides methods for manual URL control

2. **ApiClient Class** (`lib/data/api/api_client.dart`)
   - Automatically retries failed requests with fallback URL
   - Integrates seamlessly with existing API calls

3. **ConnectionManager Service** (`lib/services/connection_manager.dart`)
   - Handles periodic recovery checks
   - Manages connection status
   - Provides manual control methods

4. **ConnectionStatusWidget** (`lib/widgets/connection_status_widget.dart`)
   - UI component to display current connection status
   - Allows manual URL switching for testing/debugging

### Key Methods

```dart
// Check and switch to fallback if needed
MyHelper.switchToFallbackIfNeeded()

// Reset to primary if available
MyHelper.resetToPrimaryIfAvailable()

// Force switch to fallback
MyHelper.forceUseFallback()

// Force switch to primary
MyHelper.forceUsePrimary()

// Get current URL
MyHelper.baseUrl

// Check if using fallback
MyHelper.isUsingFallback
```

## Usage

### For Developers

The fallback system works automatically with all existing API calls. No changes are needed to existing code.

### For Testing

1. **Add the ConnectionStatusWidget** to any screen for debugging:
   ```dart
   import '../widgets/connection_status_widget.dart';
   
   // In your widget build method:
   Column(
     children: [
       // Your existing widgets
       ConnectionStatusWidget(), // Add this for testing
     ],
   )
   ```

2. **Manual Testing**:
   - Use the widget buttons to manually switch between URLs
   - Monitor the debug console for connection status messages
   - Test app functionality with both URLs

### For Users

The system works transparently. Users will experience:
- **Seamless connectivity** even during server issues
- **Automatic recovery** when the primary server comes back online
- **No manual intervention** required

## Configuration

### Timeout Settings
- **Connection test timeout**: 10 seconds
- **Recovery check interval**: 5 minutes
- **API request timeout**: 30 seconds (unchanged)

### Customization

To modify URLs or settings, edit the constants in `MyHelper`:

```dart
class MyHelper {
  static const String _primaryBaseUrl = "https://eclipse.anfaan.com/public/";
  static const String _fallbackBaseUrl = "https://eclipse.anfaan.com/";
  // ...
}
```

## Error Handling

The system handles various failure scenarios:
- **Network timeouts**
- **DNS resolution failures**
- **Server unavailability**
- **HTTP errors** (500, 502, 503, etc.)

When both URLs fail, the app returns the standard "connection_to_api_server_failed" message.

## Monitoring

In debug mode, the system logs:
- URL switching events
- Connection test results
- Fallback attempts
- Recovery operations

Check the debug console for messages like:
```
Primary URL failed, testing fallback...
Switched to fallback URL: https://eclipse.anfaan.com/
Switched back to primary URL: https://eclipse.anfaan.com/public/
```

## Benefits

1. **Improved Reliability**: App continues working during server maintenance
2. **Better User Experience**: Seamless operation without user intervention
3. **Automatic Recovery**: Returns to optimal configuration when possible
4. **Easy Debugging**: Visual status indicator and manual controls
5. **Backward Compatibility**: No changes needed to existing code

## Future Enhancements

Possible improvements:
- Multiple fallback URLs
- Smart URL selection based on response times
- Regional fallback servers
- Connection quality metrics
- User notification of fallback usage