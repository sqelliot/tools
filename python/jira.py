import requests
import json
import os
import argparse

def parse_arguments():
    parser = argparse.ArgumentParser(description='Fetch assigned tasks from Jira')
    parser.add_argument('--json', action="store_true", help='Print JSON response body')
    parser.add_argument("--select", action="store_true", help="Prompt user to select an issue key")
    return parser.parse_args()

args = parse_arguments()

# Jira API endpoint for searching issues
url = "https://resmedglobal.atlassian.net/rest/api/3/search"

# Jira username and API token (generate one from Jira settings)
username = os.getenv('ATLASSIAN_USERNAME')
api_token = os.getenv('ATLASSIAN_TOKEN')

# JQL query to search for issues assigned to the current user
jql_query = f'assignee="{username}" AND resolution = Unresolved ORDER BY  key asc'

# Define headers for authentication and content type
headers = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}

# Authentication using Basic Auth (username and API token)
auth = (username, api_token)

# Parameters for the search request
params = {
    "jql": jql_query,
    "maxResults": 25  # Number of maximum results to retrieve
}

# Sending a GET request to Jira API
response = requests.get(url, headers=headers, params=params, auth=auth)

# Checking if request was successful
if response.status_code == 200:
    # Parsing JSON response
    data = response.json()

    if args.select:
        # Prompt user to select an issue key
        print("Select an issue key:")
        for index, issue in enumerate(data['issues']):
            print(f"{index + 1}. {issue['key']}: {issue['fields']['summary']}")

        # Get user's selection
        selection = input("Enter the number corresponding to the issue key: ")

        # Validate user input and print selected key
        try:
            index = int(selection) - 1
            selected_issue_key = data['issues'][index]['key']
            print(f"{selected_issue_key}")
        except (ValueError, IndexError):
            print("Invalid selection.")
    elif args.json:
        print(json.dumps(data, indent=4))
    else:
        # Extracting relevant information (e.g., issue key, summary)
        for issue in data['issues']:
            issue_key = issue['key']
            summary = issue['fields']['summary']
            print(f"Issue Key: {issue_key}, Summary: {summary}")
else:
    print(f"Error: {response.status_code} - {response.text}")
