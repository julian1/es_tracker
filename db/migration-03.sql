
-- sequence rename to be consistent

begin;

alter sequence trades_id_seq rename to events_id_seq;

commit;
