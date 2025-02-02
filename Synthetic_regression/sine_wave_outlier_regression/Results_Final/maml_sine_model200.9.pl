��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2003385043136qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2002773479040qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2002773474912qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2002773475104q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2002773475392q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2002773477216q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2002773474912qX   2002773475104qX   2002773475392qX   2002773477216qX   2002773479040qX   2003385043136qe.@      ��8�`���V难��ڽj᝽��\���!�R��=$�y��,��R$��g��z�=q�l�Q���y��Z�ɽ6|ݽΒI�T�l��м���������f½2D9��B�=��0��<30>����]�����pɽx"��.�,��A>��"�֘�=��=�D�=,����=���=�!轞�f�Nf�=fd�M��Fx۽h�I=�<���e��
{=Tˣ=T�r=�
�A�>�tC�����¼���=� �=�|ݺ&G�=ڸ�ҭ�=� >��Ľ�
=��м~�������	Y�K
���� b;�>��g=��ܾ��c?�S�>���>ӫ�=�?��T>sﳾ�2^��y�l��>:�)>_i���R��N]��V\�<�%̾D�����>��`���B�>�c">��=�.A���>>��;?���<�?��l>�\���7��Lq=���?v.��W��kL?22�>;7�>]B���q��s�6���M7=e@�[);��8��9���;��ľ�|>C����
�~��>y	>*>�_? Y�>߫8>}z��<�ݽOӖ��>:��>_�.>a*>aF���l���߾�����>ɋ�>����V�?WI8�I=a��M�,�Z�+�<��=S�U���/�7.߽Y->���i�ؾ9W��7�=�}����0�GTb>b�����`���1u=�4���y��\^��7 >�U�M��ڿ��7�>,���,��n�?ҭ4��I���x��Jֹu��͝�n�<W?�Eɾ�3�<�s �uX�˱�</������],>��r��\��z>#	>����cFV��	��z?����?�ƽۦ�z���K��A���۫��X~j=�A��\�À�=����sվ���:�0���̛�������^�=�Vk��D�ek�<�?�B���M��g���|�<�$W=��/=t��8���E?w�=�\7�예�_۰��^^>�����rm�$jA?�
żJ%��𢾍��=*�h�/@����� ��'%��"�#t��r�<N�>�'���9�?&⑿��|����]4徂Ǟ<b+���d�~�c?������= Mc�)�>�������=s�����`���e��u�=$J׻3����4�І���;������g=��hp��&�<"� ������8��]=�qR=�|ڽ�U!�L\;@�p�����6�X����ڼ%n�� �߼?�j=eM����A#�=�f/�ݭ�;�r >��=��=<���+о�s�?<)�= �����?>��?�v/�ɀϿ�;<�9�)@�R��+B>�E~��tY�A���߿�cK?j�=d��An>�t�4��?����>���O-���̿��!����>���*�>c`��V����Ҿ��>8��5ܿ�{������vl�<�$?��=�_ ? ۽�?����>���u��7��4�����K�c?L�<�u��lX>��Z��Ce�mPž�k�5�=؂ǽ��=)>��1����=F$E��h�?��!�@>@��V4��L���LZ�2i���k��Ҟ�1I�����X�7?y5S>0%m�m��>7�d���Z>JAD>�<>��>��>��>v�>"l>�P�� w=>E�ؾ�M>a�>Ņ�>��I��.���]�K��>@)f=}�>�>��>��`�lS����=�t���=}:�<�G>?�w�/B���n�>)�>���[?�*�?,b�>�>u�h���=��N�q뎾ゾ�����R� ��Ό��p���	��/�-lƼ��B�|�߽�[��������=3������P�����=�O���T��"�32���ʵ�F��=��=�Ȱ=����ҡ<�@���� ��� f,��ʽdBX=�sߺN��D����2���>b�"�a x�����[M��D@�����C���#?�fc>Tv쾿���׹.�#j�$TN�+J��%㾴��<���<�+�����sR>/=����?#�M��ґ�ظ�<��ן�=k�׾����ߢ�ߑ׽�����6��f;Dֿ�B�}��� ?�x=�J�>&��=��y=�Ϧ�����뼝�d�u�ja>�gj��=�IR��w{>��]�]���s���~">O�վ`� =��@>��>'�@>�@d��*=?(��>̍�=y����_>�)G��� ��,�=Ei?�)�\.�=�?F�>�>U�u��b�!Ǚ��^>AOƾ����Ә������;�q��2���5?��������Kn���¶��n�:���>\)���9�z}�=e������^���j�T�K?�ٽ�8����׾��D��`e����E#���>FX��D� �M^�~������e���q��=�)ӽEf��]">)�<�TP>�6 ��V�<��
���=4�ڽ=3����=l���2 s�u�!>o0?�E��lj<n
���\< l�=��>=��=U���0B���E�Ə	��e�)�����>��<�����4�?	q���O�(�(>X�Of4���2=�K=������<�?�<�=� ˽H��7D�����&�;�7�x�缼��=]�:ꁽ6�"=���BZ��گ�h�=��(=Q!�������{�� 5�R��ȡ���I�s���B��=pys=e�"�dt=��8�+����:�������ҽ�Y�<���=���>��;���>��>S�&��?*����/>���'�پ��>]=+�,��x�=���>�S�=o3�>)��йx=�x	��̈=R?m�J>��>h�>���>��>���4S%��0����>%�=dJ�=- @h���< >S����<�"���s�k^�qn)��I?��"�h�?���=�R?�w�=-����X�Z1��^ʅ��D>���=������B>rr�=/�¼g�>ΐ�=�ie?�e�>��	>[�?z-�4����!�=��=la߽�Ex>+s�>J�b=�8�>P^��lß�Z!?pBk=K��>�XW�R��=��'��!҂=���=$ܽ��ٽ%�̼�K�2G���e��8�׭;=�H}��EP�����K}��>�`=����Խ����̍�6�f��>�=d�1���x=�>�J��1=׬A��g���������D�Lٷ=�xM���^=��<��{?!��>U��>�r����2?k"?��ռ�N.��s)>״n?��ľHh"�F�=���RG9>�~���z^�����e=;�V:k��x�">JE=��9�l_@��t���>�@a>^���Ȼ�E¾䐄�+�=��_�9
�������H?�0?�^>6J�>��>/�<.�B�2\=C�@���m��᫾q4>�Ȧ��ʽF>���n�,� �?���=P�g>��9�5��,>������=�?!��b��]�>�/>�n�>U;R?�뭽����g�Fd�>��>�C(>��?�36�u.�=%.�\��}Aa�B9��� >�����B��v>�?t��1��G���������v�U�Ő��q�=%	����=-���	�;�c����C��B�A�����<=`|����=A>�[1���ֺ��ҽ��=�p�m.���	���L�.��=�P�R= �B=kS�)?�	�̿�Ta?��G?h35?2ˊ>���?�<�=�Ƚ�ݠ��2�<�9'@�`�>=*����>�e��,���k����Y�h��O?���� I~<z�4���8?�e��o9��hS?]1?��z>�5����>%�X�]j�>�L��3u���u���?#�J?��?#�(�˺*>'�=�M�>�Ґ�h���\��� ;13�=��x�5n#��q�>^�ɾ +=+vi>�gG>��=��ν��U�N�=�쎾"��=u�(��V�=l��=��-��0i?o<�>C`�&x��9>&��=L�>�J�;9^O?�X���a��$T?��>й~>��`�D�=�=5=�f=B��;C����$���{={��~P�|#�<�kZ��
��z8=I�Ѽ��g���@��%3����b���$Q�'ʓ��Q-|����=�Z��F�	��.=�1�� <��޽�T?��k�*4=�ʣ=Z<l����u>�~��9�i�?��7�=�,����?��堽�����3�0�?a(���<��0�^x��ڽy��c�����7�/��ю�:��=����Y �>��{�k��b:���)��ި�=@5�e\7�9y�=��>��ԍZ���A�vh��;�{��2j=�����=Q݁�O����a>��>S0��q��tt�P$��M��RM2�D���*�]?L�����"��<>;����Y?�D����u���c>X���[���jr�S�>�5B>Oy��-Ӝ?�T���B������<���]`��+ٿn2��օ�?3f#��ڿ�6���۽	�H_���A�_�>�I$=�k�=��<J#��P��{��=�#�=~�=�5^�Z7:;?��F��Q��>�����fU��{�=u���*���L��=E{3����=R8�.'��H�F��^-��&'�����r�<ԕ���>��ܽA@�< ޅ:'��=R���iN=�G=���F��Oؼ��=����	��V��>���/�-?Ia�a�>g����D>�T�>/�����=wʑ?�V�=[�6=U�Ͼ���ܓK��ƽuה=8T>�ؐ=�/���/�戂�z^࿶.�>p�>�#�=s�	@�}־踼��U
��;����ؼ�<��=�7�. "���<�p>��Rʽ@=�!9=��b=�J��ɭ����=�c���=!�?�$�n�jX����:��C��o�޽�漴�ػ@9@� _m�r�=�XT=�����=�ٸ��k�;�x���4�R'� )v: Cu�/,�� �<�^>$i=Y%��b��=M)<zT7?!�ľ�|��ݻ
���[2����_<���>;S?�r�=��.�|��>��a�U>D4��l��Q�Q�>(0�O���CU�6�;g	�?d?�h�E�Ľ&�Ž���ᄾT|"���ܽ�1����<w;�&�>DՎ>�-�<�W���\}<!��=���� �=�g>Ȩ�;�J6��ḽ��=��?��]�:>�Z��Eվ�(��9���t�M���-�⽢��=G>V;HoS��D*�y����7���ҽ�������=w�����3�<z q��]�=w��<�@��(B;;��Ž�Y��)K<�P�����dY#=
4�=Z
ٽYof���<�|
��
�2bf��,�:3�>fa�=P��_���f��խ�8�2�:��=+ý�T=��,�"��=i�=s����A��\B� F���cm�du��(�㽄X��#S�A�$bU�,��;ŝƽ��N�uJ>cҦ�FV��&ԽB�X<�?�@�R�[�S��>t9�;�ٹb�6=KD@���A=��+�{�=Ϛ۽V����=[���!��.DI�N�Խk[J�o"=�ƻ�8g�<`���_N?��p��vǽ�;,�zV�t��& �=x챽�A ��>��/<�q<�=�<T���Q�̾P����[�N�]����]>B�H�E���Խ"} ���W�����R��0�:9���+ｉ��Һ����=���o�aU���n�����<�پ�����@���l$�h��
i��$�bڷ=H��q�H�bս��	�Ի�
��=>R�e<w�?��b�P<����?$of��6F��3�=Ųǿx����V!���U�����2:=v�2��y�yE��m":����H'?A�J>��> ��-4�>�?>�n5��x7=�
��\e������r�í��+���U���<??p>y����р�d�U��@*��n;�M�V�G={�2�r�=�2���-
=�ڮ�2Kݽ������Y�����x�VF�</����'=���w% >d�<F�I��=��b�w� �~?�=R�r�n�'��k:=NT<4���:�4r%��p�<�;��r:=A���{3��Da�$뙾@��=æ��<:*��#?��p���<د;�M���{�����x���ӽ3��>���=����c>j�k=�L�=��D=�;�=(�5?@;=�H���h��j��8���#=se���!=�g�=:t�>@s}�\|?��<je�@��>Ԭv>�|.>.F(����.�
�Z?���=Z�f�}��jm��'���?eC�������?v������b���ؾ⫍�Iw^��<��ְ�<b8�<!8>��t�
�	?�'m><V���@��z��7۽����Ri���v/�Ht�S��:V1��8����g��>�J�=(       'e'� I=�kФ���� a�>��>�5?��!��/?�C?�,�>�ѐ��E�>Yq
���=�L;<v��}�����>T.b=���>h���"6���z���Ӈ<�'=��?ܰ�����fm��њ�>%���.�D��⩽l�?���>)�H�5��=)��>(       3�L=�~����>�o�>��\��_�RN����2��;�?1C����;�e=��G��k[>?�8��>���<��>:������.�j��.�>?ė<|˼>�S�>n���k9>]��>ͼ���>:(�%�8ꊾeWj�ﷹ<O����¾_>�遾��z�       �X�(       ����D���C����=uU�=ڌ�>e�?�$���\=���do>L?L�>�ܝ��=Y�R8|=9�V��B'?3݋>��7��r
?��Z�Jy�>���<e"�>A�¿m}@?�O����c?���d?�»�tI�->�c�>F���8ᐿ𙆾�z;�(       h�>s����><�%�>>_r�>�H½�&ѾF( >�_��*�>�"=�u��lg>�0?��c>���=5��)��9 �>�����#��0��=n�s�k�>���=<�.���.���*[�bܽ �;?~gq>Q��=�Vn���^>�0>��J���V@�