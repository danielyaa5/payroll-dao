## Payroll DAO: Employee Payment Management in Solidity
by Daniel Yakobian

#### Overview
System holds USD, ETH, and Tokens. For simplicity USD is assumed to be a token. 
Employees can with withdraw payment due to them once a month. The employee determines how they wish 
to have their funds allocated _(i.e 50% USD, 30% ETH, 20% some token[s])._ The employee can decide 
distribution of their funds once per 6 months. 
 
#### Architecture
Contract Resolver

Resolver Client

Access Controls

CASI - Controller, Application, Storage, Interface 
* Controller
    - Only reachable from the app contract or other controllers in the ContractResolver
    - Does maths on storage
    - Validates input and output
    

