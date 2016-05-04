from parts.Part import Part


class NoOp(Part):
    def in_output(self):
        return False

    def get_bytes(self):
        return None
