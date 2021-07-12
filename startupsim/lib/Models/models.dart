class Model {
  Map<String, dynamic> user = {
    'uid': null,
    'email': null,
    'companyName': null,
  };

  Map<String, dynamic> company = {
    'companyName': null,
    'reputation': 30,
    'userBase': 0,
    'userBaseMultiplier': 1.0,
    'accountBalance': 100000,
    'level': 1,
    'exp': 0,
    'totalEmployees': 0,
    'stockValues': [0, 0, 0, 0, 0, 0],
    'totalProducts': 0,
    'products': [
      {'productName': 'Add Product'}
    ],
    'availableStocks': 20000,
    'investors': [],
    'investments': [],
    'transactions': [],
    'mails': [],
    'aiEmployees': {
      'Total': 1,
      'timePerTask': 5,
      'salary': 200,
      'morale': 70,
      'working': 0,
    },
    'uiEmployees': {
      'Total': 1,
      'timePerTask': 5,
      'salary': 200,
      'morale': 70,
      'working': 0,
    },
    'backendEmployees': {
      'Total': 1,
      'timePerTask': 5,
      'salary': 200,
      'morale': 70,
      'working': 0,
    },
    'cyberSecurityEmployees': {
      'Total': 1,
      'timePerTask': 5,
      'salary': 200,
      'morale': 70,
      'working': 0,
    },
    'databaseEmployees': {
      'Total': 1,
      'timePerTask': 5,
      'salary': 200,
      'morale': 70,
      'working': 0,
    },
    'networkEmployees': {
      'Total': 1,
      'timePerTask': 5,
      'salary': 200,
      'morale': 70,
      'working': 0,
    },
    'marketing': {
      'ongoing': false,
      'time': null,
      'reputationIncrease': null,
      'userBaseMultiplier': null,
      'cost': 0,
      'options': [],
    },
    'recruitment': {
      'ongoing': false,
      'time': null,
      'cost': 0,
      'uiEmployees': 0,
      'aiEmployees': 0,
      'backendEmployees': 0,
      'cyberSecurityEmployees': 0,
      'databaseEmployees': 0,
      'networkEmployees': 0,
    },
  };

  Map<String, dynamic> product = {
    'productName': null,
    'userBase': 0,
    'revenueRate': 0,
    'usability': 0,
    'scalability': 0,
    'security': 0,
    'ongoingTasks': null,
    'finishedTasks': [],
    'majorVersion': 0,
    'minorVersion': 1,
    'patchesVersion': 0,
    'ui': 0,
    'backend': 0,
    'database': 0,
    'network': 0,
    'ai': 0,
    'cyberSecurity': 0,
    'funded': false,
    'fundingAmount': 0,
    'fundedBy': 'ikayi',
  };

  Map<String, dynamic> transactions = {
    'type': null,
    'amount': 0,
    'purpose': null,
    'time': null,
  };

  Map<String, dynamic> ongoingTasks = {
    'type': 'ongoing',
    'eta': null,
    'uiComponents': 0,
    'aiComponents': 0,
    'backendComponents': 0,
    'cyberSecurityComponents': 0,
    'databaseComponents': 0,
    'networkComponents': 0,
    'uiEmployees': 0,
    'aiEmployees': 0,
    'backendEmployees': 0,
    'cyberSecurityEmployees': 0,
    'databaseEmployees': 0,
    'networkEmployees': 0,
    'estimatedCost': 0,
    'userIncrease': 0,
    'scalabilityIncrease': 0,
    'usabilityIncrease': 0,
    'securityIncrease': 0,
  };

  Map<String, dynamic> finishedTasks = {
    'type': 'finished',
    'time': null,
    'cost': 0,
    'userIncrease': 0,
    'majorVersion': 0,
    'minorVersion': 1,
    'patchesVersion': 0,
  };

  Map<String, dynamic> marketing = {
    'ongoing': false,
    'time': null,
    'isFinished': false,
    'reputationIncrease': null,
    'userBaseMultiplier': null,
    'cost': null,
  };

  Map<String, dynamic> recruitment = {
    'ongoing': false,
    'time': null,
    'isFinished': false,
    'cost': null,
    'uiEmployees': 0,
    'aiEmployees': 0,
    'backendEmployees': 0,
    'cyberSecurityEmployees': 0,
    'databaseEmployees': 0,
    'networkEmployees': 0,
  };
}
