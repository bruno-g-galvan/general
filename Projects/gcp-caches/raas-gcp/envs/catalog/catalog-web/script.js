// List of all JSON file paths relative to script.js
const jsonFiles = [
    'data/prod-europe-west1-memcache.json',
    'data/prod-europe-west1-redis.json',
    'data/prod-us-central1-memcache.json',
    'data/prod-us-central1-redis.json',
    'data/stable-europe-west1-memcache.json',
    'data/stable-europe-west1-redis.json',
    'data/stable-us-central1-memcache.json',
    'data/stable-us-central1-redis.json'
];

// Fetch all JSON files and process them
Promise.all(
    jsonFiles.map(file => 
        fetch(file)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Error loading file ${file}: ${response.statusText}`);
                }
                return response.json(); // Parse the JSON data
            })
            .catch(error => {
                console.error('Error:', error);
                return {}; // Return an empty object on error to avoid breaking the loop
            })
    )
).then(dataArrays => {
    // Flatten the object data into an array of entries
    const allData = dataArrays.flatMap(data => {
        return Object.values(data); // Flatten each file's object into an array of service entries
    });

    // Generate the table with the flattened data
    generateTable(allData);
}).catch(error => console.error('Error fetching data:', error));

// Function to calculate the Tier according to memory size
function getTier(memory_size) {
    if (memory_size >= 1 && memory_size <= 4) return 'M1';
    if (memory_size >= 5 && memory_size <= 10) return 'M2';
    if (memory_size >= 11 && memory_size <= 35) return 'M3';
    if (memory_size >= 36 && memory_size <= 100) return 'M4';
    if (memory_size > 100 && memory_size < 1000) return 'M5';
    return 'N/A';
}

// Function to calculate the capacity based on node type and shard count
function getCapNodeType(node_type, shard_count) {
    if (node_type === 'REDIS_SHARED_CORE_NANO') return (shard_count * 1.12).toFixed(2);
    if (node_type === 'REDIS_STANDARD_SMALL') return (shard_count * 5.2).toFixed(2);
    if (node_type === 'REDIS_HIGHMEM_MEDIUM') return (shard_count * 10.4).toFixed(2);
    if (node_type === 'REDIS_HIGHMEM_XLARGE') return (shard_count * 46.4).toFixed(2);
    return 'N/A';
}

// Function to generate the table
function generateTable(data) {
    const tableBody = document.getElementById('table-body');
    let rowsHTML = '';

    for (const entry of data) {
        const memorySize = entry.memory_size || 0;
        const nodeType = entry.node_type || '';
        const shardCount = entry.shard_count || 0;
        const tier = getTier(memorySize);
        const capacity = getCapNodeType(nodeType, shardCount);

        rowsHTML += `
            <tr>
                <td>${entry.name || 'N/A'}</td>
                <td>${entry.region || 'N/A'}</td>
                <td>${entry.type || 'N/A'}</td>
                <td>
                    ${entry.service ? `<a href="https://services.groupondev.com/services/${entry.service}" target="_blank">${entry.service}</a>` : 'N/A'}
                </td>
                <td>${nodeType || tier}</td>
                <td>${shardCount || 'N/A'}</td>
                <td>${memorySize || capacity || 'N/A'}</td>
                <td>${entry.cache_cname || 'N/A'}</td>
                <td>
                    ${entry.jira_ticket ? `<a href="https://jira.groupondev.com/browse/${entry.jira_ticket}" target="_blank">${entry.jira_ticket}</a>` : 'N/A'}
                </td>
            </tr>
        `;
    }

    tableBody.innerHTML = rowsHTML;
}
