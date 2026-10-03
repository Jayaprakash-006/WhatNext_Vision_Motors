public class VehicleOrderTriggerHandler {

    public static void handle(
        List<Vehicle_Order__c> newOrders,
        Map<Id, Vehicle_Order__c> oldMap,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isBefore
    ) {

        if (isBefore) {
            validateStock(newOrders);
        } else {
            updateVehicleStock(newOrders, oldMap);
        }
    }

    private static void validateStock(List<Vehicle_Order__c> orders) {

        Set<Id> vehicleIds = new Set<Id>();

        for (Vehicle_Order__c order : orders) {
            if (order.Vehicle__c != null) {
                vehicleIds.add(order.Vehicle__c);
            }
        }

        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>(
            [SELECT Id, Stock_Quantity__c
             FROM Vehicle__c
             WHERE Id IN :vehicleIds]
        );

        for (Vehicle_Order__c order : orders) {
            if (order.Vehicle__c != null &&
                vehicles.containsKey(order.Vehicle__c) &&
                vehicles.get(order.Vehicle__c).Stock_Quantity__c <= 0) {

                order.addError(
                    'This vehicle is out of stock. Order cannot be placed.'
                );
            }
        }
    }

    private static void updateVehicleStock(
        List<Vehicle_Order__c> orders,
        Map<Id, Vehicle_Order__c> oldMap
    ) {

        Set<Id> vehicleIds = new Set<Id>();

        for (Vehicle_Order__c order : orders) {
            if (order.Status__c == 'Confirmed' &&
                (oldMap == null ||
                 oldMap.get(order.Id).Status__c != 'Confirmed') &&
                order.Vehicle__c != null) {

                vehicleIds.add(order.Vehicle__c);
            }
        }

        if (vehicleIds.isEmpty()) {
            return;
        }

        List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();

        for (Vehicle__c vehicle : [
            SELECT Id, Stock_Quantity__c, Status__c
            FROM Vehicle__c
            WHERE Id IN :vehicleIds
        ]) {

            if (vehicle.Stock_Quantity__c > 0) {
                vehicle.Stock_Quantity__c =
                    vehicle.Stock_Quantity__c - 1;

                if (vehicle.Stock_Quantity__c == 0) {
                    vehicle.Status__c = 'Out of Stock';
                }

                vehiclesToUpdate.add(vehicle);
            }
        }

        if (!vehiclesToUpdate.isEmpty()) {
            update vehiclesToUpdate;
        }
    }
}