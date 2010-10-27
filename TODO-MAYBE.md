# TODO!! (MAYBE) #
* Job queue for dispatching notifications. Probably use resque.
* Persistence should be rewritten with a git-esque "shapshot" model:
  Node data that usually stays constant for a long time (run list, roles, recipes)
  should be normalized in the db so we can store lots.
