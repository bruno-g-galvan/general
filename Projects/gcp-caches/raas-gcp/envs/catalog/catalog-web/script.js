// Cargar el archivo JSON y generar la tabla
fetch('instances.json')
    .then(response => {
        if (!response.ok) {
            throw new Error(`Error al cargar el archivo: ${response.statusText}`);
        }
        return response.json();
    })
    .then(data => generateTable(data))
    .catch(error => console.error('Error:', error));

// Función para calcular el Tier según el tamaño de memoria
function getTier(memory_size) {
    if (memory_size >= 1 && memory_size <= 4) {
        return 'M1';
    } else if (memory_size >= 5 && memory_size <= 10) {
        return 'M2';
    } else if (memory_size >= 11 && memory_size <= 35) {
        return 'M3';
    } else if (memory_size >= 36 && memory_size <= 100) {
        return 'M4';
    } else if (1000 > memory_size > 100) {
        return 'M5';
    }
    return 'N/A'; // Default tier if memory_size is undefined or doesn't match any range
}

// Función para calcular el Tier según el tamaño de memoria
function getCapNodeType(node_type, shard_count) {
    if (node_type == 'REDIS_SHARED_CORE_NANO') {
        number = shard_count * 1.12
        return number.toFixed(2);
    } else if (node_type == 'REDIS_STANDARD_SMALL') {
        number = shard_count * 5.2
        return number.toFixed(2);
    } else if (node_type == 'REDIS_HIGHMEM_MEDIUM') {
        number = shard_count * 10.4
        return number.toFixed(2);
    } else if (node_type == 'REDIS_HIGHMEM_XLARGE') {
        number = shard_count * 46.4
        return number.toFixed(2);
    }
    return 'N/A'; // Default tier if memory_size is undefined or doesn't match any range
}

// Función para generar la tabla
function generateTable(data) {
    const tableBody = document.getElementById('table-body');
    let rowsHTML = '';

    for (const key in data) {
        const entry = data[key];
        const memorySize = entry.memory_size || 0;  // Default to 0 if memory_size is undefined
        const nodeType = entry.node_type || 0;
        const shardCount = entry.shard_count || 0;
        const tier = getTier(memorySize);  // Calculate the tier based on memory_size
        const capacity = getCapNodeType(nodeType, shardCount);

        rowsHTML += `
            <tr>
                <td>${entry.name || 'N/A'}</td>
                <td>${entry.region || 'N/A'}</td>
                <td>${entry.type || 'N/A'}</td>
                <td>
                    ${entry.service ? 
                        `<a href="https://services.groupondev.com/services/${entry.service}" target="_blank">${entry.service}</a>` 
                        : 'N/A'}
                </td>
                <td>${entry.node_type || tier}</td>
                <td>${entry.shard_count || 'N/A'}</td>
                <td>${memorySize || capacity || 'N/A'}</td>
                <td>${entry.cache_cname || 'N/A'}</td>
                <td>
                    ${entry.jira_ticket ? 
                        `<a href="https://jira.groupondev.com/browse/${entry.jira_ticket}" target="_blank">${entry.jira_ticket}</a>` 
                        : 'N/A'}
                </td>
            </tr>
        `;
    }

    tableBody.innerHTML = rowsHTML;
}
