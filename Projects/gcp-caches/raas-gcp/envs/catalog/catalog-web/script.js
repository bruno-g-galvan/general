let allData = [];
let priceData = {};

// Add event listeners for filters
document.getElementById('region-filter').addEventListener('change', function() {
    filterTable(); // Call filterTable on change without passing arguments
});
document.getElementById('type-filter').addEventListener('change', function() {
    filterTable(); // Call filterTable on change without passing arguments
});

// Function to filter and generate the table based on the selected filters
function filterTable() {
    const regionFilter = document.getElementById('region-filter').value.toLowerCase();
    const typeFilter = document.getElementById('type-filter').value.toLowerCase();

    const filteredData = allData.filter(entry => {
        let matches = true;

        if (regionFilter && entry.region && !entry.region.toLowerCase().includes(regionFilter)) {
            matches = false;
        }

        if (typeFilter && entry.type && !entry.type.toLowerCase().includes(typeFilter)) {
            matches = false;
        }

        return matches;
    });

    generateTable(filteredData, priceData);  // Re-generate table with filtered data
}

// Fetch all data
async function fetchData() {
    try {
        const dataArrays = await Promise.all(
            jsonFiles.map(file =>
                fetch(file).then(response => {
                    if (!response.ok) {
                        throw new Error(`Error loading file ${file}: ${response.statusText}`);
                    }
                    return response.json(); // Parse the JSON data
                })
            )
        );

        const fetchedPriceData = await fetch(priceFile)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Error loading price file ${priceFile}: ${response.statusText}`);
                }
                return response.json(); // Parse the price JSON data
            });

        allData = dataArrays.flatMap(data => Object.values(data)); // Flatten all the data files
        priceData = fetchedPriceData;

        generateTable(allData, priceData); // Initial table generation
    } catch (error) {
        console.error('Error fetching data:', error);
    }
}

// List of all JSON file paths relative to script.js (excluding the new JSON with prices)
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

// Path to the new JSON file with prices
const priceFile = 'prices.json';

Promise.all([
    // Fetch the other JSON files (without prices)
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
    ),
    // Fetch the price JSON file separately
    fetch(priceFile)
        .then(response => {
            if (!response.ok) {
                throw new Error(`Error loading price file ${priceFile}: ${response.statusText}`);
            }
            return response.json(); // Parse the price JSON data
        })
        .catch(error => {
            console.error('Error loading price file:', error);
            return {}; // Return an empty object on error
        })
]).then(([dataArrays, fetchedPriceData]) => {
    // Flatten the object data into an array of entries (for the main JSON files)
    allData = dataArrays.flatMap(data => {
        return Object.values(data); // Flatten each file's object into an array of service entries
    });

    // Store the price data
    priceData = fetchedPriceData;

    // Generate the table with the main data
    generateTable(allData, priceData);  // Ensure the table is generated initially
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

function getPricing(priceData, region, type, nodeType, tier, memorySize, shardCount, nodeCount) {
    // Check if the price exists for the given region, type, and tier (Redis Instances)
    if (priceData[region] && priceData[region][type] && priceData[region][type][tier]) {
        return (priceData[region][type][tier] * memorySize * 730).toFixed(2);
    }

    // Check for Redis Clusters (by nodeType)
    if (priceData[region] && priceData[region][type] && priceData[region][type][nodeType]) {
        return (priceData[region][type][nodeType] * shardCount * 730).toFixed(2);
    }

    // Check for Memcache pricing based on memorySize
    if (priceData[region] && priceData[region][type]) {
        if ((memorySize / 1024) <= 4) {
            return (priceData[region][type]['node<=4'] * (memorySize / 1024) * nodeCount * 730).toFixed(2) || 'N/A';  // Fallback if the 'node<=4' pricing doesn't exist priceData[region][type]['node<=4']
        } else {
            return (priceData[region][type]['node>4'] * (memorySize / 1024) * nodeCount * 730).toFixed(2) || 'N/A';  // Fallback if the 'node>4' pricing doesn't exist
        }
    }

    // Fallback if no valid pricing is found
    return 'N/A';
}

// Function to generate the table
function generateTable(data, priceData) {
    const tableBody = document.getElementById('table-body');
    let rowsHTML = '';

    for (const entry of data) {
        const memorySize = entry.memory_size || 0;
        const nodeType = entry.node_type || '';
        const nodeCount = entry.node_count || ''; 
        const type = entry.type || ''; 
        const region = entry.region || ''; 
        const shardCount = entry.shard_count || 0;
        const tier = getTier(memorySize);
        const capacity = getCapNodeType(nodeType, shardCount);
        const price = getPricing(priceData, region, type, nodeType, tier, memorySize, shardCount, nodeCount);

        rowsHTML += `
            <tr>
                <td>${entry.name || 'N/A'}</td>
                <td>${entry.region || 'N/A'}</td>
                <td>${entry.type || 'N/A'}</td>
                <td>
                    ${entry.service ? `<a href="https://services.groupondev.com/services/${entry.service}" target="_blank">${entry.service}</a>` : 'N/A'}
                </td>
                <td>${nodeType || tier}</td>
                <td>${shardCount || nodeCount || 'N/A'}</td>
                <td>${memorySize || capacity || 'N/A'}</td>
                <td>${entry.cache_cname || 'N/A'}</td>
                <td>
                    ${entry.jira_ticket ? `<a href="https://jira.groupondev.com/browse/${entry.jira_ticket}" target="_blank">${entry.jira_ticket}</a>` : 'N/A'}
                </td>
                <td>${price || 'N/A'}</td>
                <td>
                    ${entry.service ? `<a href="https://grafana.com/" target="_blank"><i class="fas fa-chart-line"></i></a>` : 'N/A'}
                </td>
            </tr>
        `;
    }

    tableBody.innerHTML = rowsHTML;
}

// Fetch and load data
fetchData();