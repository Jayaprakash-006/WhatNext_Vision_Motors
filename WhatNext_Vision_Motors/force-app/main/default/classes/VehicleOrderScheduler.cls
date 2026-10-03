global class VehicleOrderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new VehicleOrderBatch(), 50);
    }
}