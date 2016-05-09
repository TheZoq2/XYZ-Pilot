from parts.Part import Part


class Comment(Part):
    def occupied_addresses(self):
        return 0

    def in_output(self):
        return False

    def get_bytes(self):
        return None
