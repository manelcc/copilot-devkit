# Kotlin Documentation Comment Template

Use this template to create clear and informative documentation comments for Kotlin classes, objects, or functions. Follow the structure below to ensure consistency and readability.

---

/**
 * [Short Description]
 *
 * [Long Description]
 *
 * @see [RelatedClassOrFunction]
 *
 * Example usage:
 * ```kotlin
 * [Example code demonstrating usage]
 * ```
 */

---

## Instructions

1. **Short Description**: Briefly describe the purpose of the class, object, or function.
2. **Long Description**: Explain what the code does, its context, and any important details.
3. **@see Tag**: Reference related classes or functions for further reading.
4. **Example Usage**: Provide a code snippet showing how to use the class or function.
5. **Additional Examples**: Add more examples for other related use cases or providers.

## Guidelines
1. Document each parameter using @param
    - Use square brackets [] for optional parameters
    - Include default values if applicable
2. Document return value using @returns
3. Include examples using @example
4. Keep indentation consistent
5. Add empty lines between major sections

## Common Tags

- @param - Document a parameter
- @returns - Document the return value
- @example - Show usage examples
- @since - Version when feature was added
- @deprecated - Mark as deprecated

### Example

/**
 * Dependency Injection module for prompt providers.
 *
 * This module configures and provides singleton instances of prompt providers
 * used by the MCP server to retrieve and manage various types of prompts.
 *
 * @see RequirementsPromptProvider
 *
 * Example usage:
 * ```kotlin
 * val promptProvider: RequirementsPromptProvider = get()
 * val requirementsPrompt = promptProvider.getPrompt("user_requirements")
 * ```
 *
 * Additional examples for other prompt types:
 * - InvoicePromptProvider: Provides prompts for invoice generation and processing
 *   ```kotlin
 *   val invoicePrompt = invoicePromptProvider.getPrompt("invoice_template")
 *   ```
 */

---

Use this template for all Kotlin documentation comments to maintain clarity and consistency throughout your codebase.