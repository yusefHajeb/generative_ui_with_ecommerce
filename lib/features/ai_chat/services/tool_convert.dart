/// Converter to use Ollama-style Tool definitions with Gemini API
/// This allows you to define tools once and use them with different LLM providers

/// Ollama-style tool definition (simplified version)
class Tool {
  final ToolFunction function;

  const Tool({required this.function});

  /// Convert Ollama Tool to Gemini format
  Map<String, dynamic> toGemini() {
    return <String, dynamic>{
      'name': function.name,
      'description': function.description,
      'parameters': _convertParameters(function.parameters),
    };
  }

  Map<String, dynamic> _convertParameters(Map<String, dynamic> params) {
    final converted = <String, dynamic>{};

    // Convert 'type' from lowercase to uppercase
    if (params.containsKey('type')) {
      converted['type'] = (params['type'] as String).toUpperCase();
    }

    // Convert 'properties' recursively
    if (params.containsKey('properties')) {
      final properties = params['properties'] as Map;
      final convertedProperties = <String, dynamic>{};

      properties.forEach((key, value) {
        if (value is Map) {
          final prop = <String, dynamic>{};

          // Convert type to uppercase
          if (value.containsKey('type')) {
            prop['type'] = (value['type'] as String).toUpperCase();
          }

          // Copy other fields as-is
          value.forEach((k, v) {
            if (k != 'type') {
              prop[k] = v;
            }
          });

          convertedProperties[key as String] = prop;
        }
      });

      converted['properties'] = convertedProperties;
    }

    // Copy other fields
    params.forEach((key, value) {
      if (key != 'type' && key != 'properties') {
        converted[key] = value;
      }
    });

    return converted;
  }
}

class ToolFunction {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  const ToolFunction({
    required this.name,
    required this.description,
    required this.parameters,
  });
}

/// Helper to convert multiple Ollama tools to Gemini format
List<Map<String, dynamic>> convertToolsToGemini(List<Tool> tools) {
  return [
    <String, dynamic>{
      'functionDeclarations': tools.map((tool) => tool.toGemini()).toList(),
    },
  ];
}

/// Example usage:
/// ```dart
/// final ollamaTool = Tool(
///   function: ToolFunction(
///     name: 'get_account_info',
///     description: 'Get account info',
///     parameters: {
///       'type': 'object',
///       'properties': {
///         'accountType': {
///           'type': 'string',
///           'description': 'Account type'
///         }
///       }
///     }
///   )
/// );
///
/// // Convert to Gemini format
/// final geminiTools = convertToolsToGemini([ollamaTool]);
/// ```
