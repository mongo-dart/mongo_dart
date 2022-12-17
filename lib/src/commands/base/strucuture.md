# Commands classes structure

                                        OperationBase
                                               |
                           +-------------------------------------+
                DbAdminCommandOperation                    ServerCommand
                                                                 |
                                                           SimpleCommand
                                                                 |
                                                          CommandOperation

## OperationBase

- Manages Aspects
- Manages Session
- Defines execute and executeOnServer Methods

### Db Admin Command Operation
