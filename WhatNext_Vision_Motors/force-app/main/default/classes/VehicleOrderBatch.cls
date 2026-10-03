public class VehicleOrderBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Vehicle__c, Status__c
            FROM Vehicle_Order__c
            WHERE Status__c = 'Pending'
            AND Vehicle__c != null
        ]);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Vehicle_Order__c> orders
    ) {

        Set<Id> vehicleIds = new Set<Id>();

        for (Vehicle_Order__c order : orders) {
            vehicleIds.add(order.Vehicle__c);
        }

        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>(
            [
                SELECT Id, Stock_Quantity__c
                FROM Vehicle__c
                WHERE Id IN :vehicleIds
            ]
        );

        List<Vehicle_Order__c> ordersToUpdate =
            new List<Vehicle_Order__c>();

        for (Vehicle_Order__c order : orders) {

            Vehicle__c vehicle = vehicles.get(order.Vehicle__c);

            if (vehicle != null &&
                vehicle.Stock_Quantity__c > 0) {

                order.Status__c = 'Confirmed';
                ordersToUpdate.add(order);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Vehicle Order Batch completed successfully.');
    }
}