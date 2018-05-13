var nppayAddr = '0xB58752dD8Fd4B14823A312686AB0B43773fe155b';
var userAccount  = "0xB919672135D9B64c3131b24Ed23755550Cba1888";

var abi = [
	{
		"constant": true,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			},
			{
				"name": "solutionId",
				"type": "uint256"
			}
		],
		"name": "can_trigger_auto_verification",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			},
			{
				"name": "solutionId",
				"type": "uint256"
			}
		],
		"name": "request_reward",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "clauses",
				"type": "string"
			},
			{
				"name": "assignment",
				"type": "string"
			}
		],
		"name": "verify_assignment_old",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			}
		],
		"name": "get_solution",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			}
		],
		"name": "get_SATProblem_info",
		"outputs": [
			{
				"name": "issuer",
				"type": "address"
			},
			{
				"name": "url",
				"type": "string"
			},
			{
				"name": "problem_hash",
				"type": "bytes32"
			},
			{
				"name": "num_vars",
				"type": "uint256"
			},
			{
				"name": "num_clauses",
				"type": "uint256"
			},
			{
				"name": "reward",
				"type": "uint256"
			},
			{
				"name": "solved",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			},
			{
				"name": "hashId",
				"type": "uint256"
			},
			{
				"name": "assignment",
				"type": "string"
			}
		],
		"name": "proposeSATSolution",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "url",
				"type": "string"
			},
			{
				"name": "problem_hash",
				"type": "bytes32"
			},
			{
				"name": "num_vars",
				"type": "uint256"
			},
			{
				"name": "num_clauses",
				"type": "uint256"
			},
			{
				"name": "reward",
				"type": "uint256"
			}
		],
		"name": "createSATProblem",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "satToOwner",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "get_balance",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "retrieve_reward",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			},
			{
				"name": "solutionId",
				"type": "uint256"
			},
			{
				"name": "evidence",
				"type": "uint256"
			},
			{
				"name": "trigger_verify",
				"type": "bool"
			},
			{
				"name": "vote_up",
				"type": "bool"
			}
		],
		"name": "vote_SAT",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			},
			{
				"name": "solutionId",
				"type": "uint256"
			}
		],
		"name": "can_trigger_manual_verification",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "clause",
				"type": "string"
			},
			{
				"name": "assignment",
				"type": "string"
			}
		],
		"name": "verify_assignment",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "problemId",
				"type": "uint256"
			},
			{
				"name": "hash",
				"type": "bytes32"
			}
		],
		"name": "proposeSATSolutionHash",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "problemId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "solutionId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "vote",
				"type": "bool"
			},
			{
				"indexed": false,
				"name": "voter",
				"type": "address"
			}
		],
		"name": "Vote_Cast",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "problemId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "solutionId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "result",
				"type": "bool"
			}
		],
		"name": "Verification_Performed",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "problemId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "hashId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "time_proposed",
				"type": "uint256"
			}
		],
		"name": "SATSolutionHashProposed",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "problemId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "hashId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "solutionId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "time_proposed",
				"type": "uint256"
			}
		],
		"name": "SATSolutionProposed",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "problemId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "num_vars",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "num_clauses",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "reward",
				"type": "uint256"
			}
		],
		"name": "New_SAT_Problem",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	}
]