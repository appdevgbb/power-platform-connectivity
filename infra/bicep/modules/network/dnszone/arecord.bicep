param dnsZoneName string
param records array

resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [for record in records: {
  name: '${dnsZoneName}/${record.name}'
  properties: {
    aRecords: [
      {
        ipv4Address: record.ipAddress
      }
    ]
    ttl: 30
  }
}]
