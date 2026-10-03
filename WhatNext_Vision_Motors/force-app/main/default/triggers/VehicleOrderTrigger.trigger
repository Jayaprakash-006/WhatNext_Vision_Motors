trigger VehicleOrderTrigger on Vehicle_Order__c (
    before insert,
    before update,
    after insert,
    after update
) {
    VehicleOrderTriggerHandler.handle(
        Trigger.new,
        Trigger.oldMap,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isBefore
    );
}