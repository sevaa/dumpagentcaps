# Description

This extension provides a build/release task that retrieves the user defined capabilities of the current
agent, and saves them as variables.

Retrieving agent data is a privileged operation. Depending on the value of the Security parameter,
you have to grant the **Reader** role to the right account - either directly or via group membership.
If you don't, you'll get the error message "No agent found for pool NNN with identifier MMM."

With Security set to "Context connection", the Reader needs to be granted to an artificial account called **Project Collection Build Service (COLL_NAME)**, where COLL_NAME corresponds to the collection where your pipeline (definition) resides.

If the Security is set to Personal Access Token, and the respective PAT was created with limited scope,
the PAT needs to have the **Agent pools (read)** right. In addition, the user who provided the PAT
needs to have the Reader role on the agent pool, and the Azure DevOps instance needs to be accessed via a HTTPS URL.

Since the task is implemented in PowerShell, only Windows agents are supported.
