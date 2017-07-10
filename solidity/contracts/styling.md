### Solidity Style Conventions

#### Code Naming
* Function names: camelCase
* Function arguments: snake_case prefixed with _
* Constant variables: SCREAMING_SNAKE_CASE
* Public and private state variables: snake_case
* Local variables: snake_case 
* Return variables: snake_case prefixed with _
* Enums: PascalCase, suffix with Enum
* Events: PascalCase, suffix with Event
* Mappings: PascalCase, suffix with Map (avoid plural name, implied)
* Structs: PascalCase
* Struct Keys: snake_case
* Contracts: PascalCase
* Contract variables: camelCase

#### File Naming
* Contracts: PascalCase, name matches constructor
* Controllers: Noun (prefer plurals) + Ctrl

#### Line Conventions
* Single line if statements if possible (no single line if else though)
* Remove nesting with return statements
* 2 new lines after functions
* Function declarations
    - Line 1 => Inputs and privacy private/public/internal
    - Line 2 => Built in modifiers constant/payable
    - Line 3 => Custom modifiers
    - Line 4 => Return (always named variable return)
* Brackets on new line
* New line after for loop block (not including nested for loop blocks)
* Layout
    - Libraries
    - Constants
    - Contract declarations
    - Declarations from most complex to least
    - Modifiers
    - Constructor
    - Public Functions
    - Internal/Private Functions


#### Preferences
* Use named variables for return values
* Explicitly state public/internal/private for state variables
* If you split a function declaration into lines, split at return
* `x == false` over `(!x)`
* `uint256` over `uint`
* onlyAdmin functions should revert not throw, because it's a trusted account

#### Security Patterns
* CEI: Checks-Effects-Interactions
* No var in for loops, use uint256 to prevent integer overflow
* `require` vs. `assert`
    - Use `require` for check input values and also any values on `msg`
    - Use `assert` for all other throw checks

#### Abbreviations
* ts = Timestamp
* amt = Amount
* usd = US Dollar
* adr = Address

#### Other
* 1 month = 30 days